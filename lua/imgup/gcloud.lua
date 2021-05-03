local Job = require 'plenary.job'
local nanoid = require('nanoid')

local M = {}

local function ready()
  if vim.g["imgup#gcloud#bucket_name"] == nil then
    error("set g:imgup#gcloud#bucket_name")
  end
  if vim.g["imgup#gcloud#host_name"] == nil then
    error("set imgup#gcloud#host_name")
  end
end
M.ready = ready

local function has(origin)
  local url = require('resty.url').parse(origin)
  if url == vim.g["imgup#gcloud#host_name"] then
    return true
  end
  return false
end
M.has = has

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

local function exist(path)
  local ls = Job:new({
    command = 'gsutil',
    args = {'ls', path},
    enable_recording = true,
  })
  local result, code = ls:sync()
  if code == 0 and result == path then
    return true
  end
  local errors = ls:stderr_result()
  if not (code == 1 and #errors > 0 and errors[1] == "CommandException: One or more URLs matched no objects.") then
    error(string.format('failed to check existance of %s: %s (%d)', path, table.concat(errors, '\n'), code))
  end
  return false
end

local function guess_mimetype(self)
  return require('imgup.puremagic.puremagic').via_path(path)
end

local function guess_ext(self)
  local mime = self.mimetype()
  if mime == nil then
    return nil
  end
  if vim.tbl_contains({'image/png', 'image/jpeg', 'image/gif', 'image/tiff', 'image/webp'}, mime) then
    return '.' .. string.sub(mime, 7)
  end
  return nil
end

local function upload(path)
  local name = nanoid() .. guess_ext(path)

  local prefix = vim.g['imgup#gcloud#prefix']
  if prefix ~= nil then
    name = string.gsub(prefix, '^/+|/+$', '') .. '/' .. name
  end

  local bucket_name = vim.g['imgup#gcloud#bucket_name']
  local gspath = 'gs://' .. bucket_name .. '/' .. name

  if exist(gspath) then
    error(string.format('%s is already exist', gspath))
  end

  local cp = Job:new({
    command = 'gsutil',
    args = {'cp', source.path, gspath},
    enable_recording = true,
  })
  _, code = cp:sync()
  if code ~= 0 then
    local errors = cp:stderr_result()
    error(string.format('failed to upload %s to %s: %s (%d)', source.path, gspath, table.concat(errors, '\n'), code))
  end

  return string.format('https://%s/%s', vim.g['imgup#gcloud#host_name'], name)
end

M.deploy = function(path, origin)
  local prev_conf = switch_conf(vim.g['imgup#gcloud#config_name'])
  local success, ret = pcall(upload, path)
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
