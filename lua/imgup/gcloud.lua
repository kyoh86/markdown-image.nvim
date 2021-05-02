local Job = require 'plenary.job'

local M = {}

local function is_valid()
  if vim.g["imgup#gcloud#bucket_name"] == nil then
    return false, "set g:imgup#gcloud#bucket_name"
  end
  if vim.g["imgup#gcloud#host_name"] == nil then
    return false, "set imgup#gcloud#host_name"
  end
  return true
end
M.is_valid = is_valid

local function switch_conf(name)
  if name == nil then
    return nil
  end

  local result, code = Job:new({
    command = 'gcloud',
    args = {'config', 'configurations', 'list', '--filter', 'IS_ACTIVE:true', '--format', 'json'},
    env = vim.env,
    enable_recording = true,
  }):sync()
  if code ~= 0 then
    error(string.format('failed to list gcloud configurations (%d)', code))
  end

  local conf_active = vim.fn.json_decode(vim.fn.join(result, ''))[1]['name']
  if conf_active == name or conf_active == nil then
    return nil
  end

  _, code = Job:new({
    command = 'gcloud',
    args = {'config', 'configurations', 'activate', name},
    env = vim.env,
  }):sync()
  if code ~= 0 then
    error(string.format('failed to acitvate gcloud configuration %s (%d)', name, code))
  end

  print(string.format("activated gcloud configuration %s", name))
  return conf_active
end

local function upload_core(source, name)
  local prefix = vim.g['imgup#gcloud#prefix']
  if prefix ~= nil then
    name = string.gsub(prefix, '^/+|/+$', '') .. '/' .. name
  end

  local bucket_name = vim.g['imgup#gcloud#bucket_name']
  local gspath = 'gs://' .. bucket_name .. '/' .. name

  local ls = Job:new({
    command = 'gsutil',
    args = {'ls', gspath},
    enable_recording = true,
  })
  local result, code = ls:sync()
  if code == 0 and result == gspath then
    error(string.format('%s is already exist', gspath))
  end
  local errors = ls:stderr_result()
  if not (code == 1 and #errors > 0 and errors[1] == "CommandException: One or more URLs matched no objects.") then
    error(string.format('failed to check existance of %s: %s (%d)', gspath, table.concat(errors, '\n'), code))
  end

  local cp = Job:new({
    command = 'gsutil',
    args = {'cp', source, gspath},
    enable_recording = true,
  })
  _, code = cp:sync()
  if code ~= 0 then
    local errors = cp:stderr_result()
    error(string.format('failed to upload %s to %s: %s (%d)', source, gspath, table.concat(errors, '\n'), code))
  end

  return string.format('https://%s/%s', vim.g['imgup#gcloud#host_name'], name)
end

M.upload = function(path, name)
  local prev_conf = switch_conf(vim.g['imgup#gcloud#config_name'])
  local success, ret = pcall(upload_core, path, name)
  if prev_conf then
    switch_conf(prev_conf)
  end
  if success then
    return ret
  else
    error(ret)
  end
end
return M
