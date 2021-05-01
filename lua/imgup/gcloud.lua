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

  return conf_active
end

local function upload_core(source, name)
  local bucket_name = vim.g['imgup#gcloud#bucket_name']
  local prefix = string.gsub(vim.g['imgup#gcloud#prefix'], '^/+|/+$', '')
  local gspath = 'gs://' .. bucket_name
  if prefix ~= nil then
    gspath = gspath .. '/' .. prefix .. '/'
  end
  gspath = gspath .. name

  local ls = Job:new({
    command = 'gsutil',
    args = {'ls', gspath},
    env = vim.env,
    enable_recording = true,
  })
  local result, code = ls:sync()
  if code == 0 and result == gspath then
    error(string.format('%s is already exist', gspath))
  end
  if not (code == 1 and ls:stderr_result() == "CommandException: One or more URLs matched no objects.") then
    error(string.format('failed to check existance of %s (%d)', gspath, code))
  end

  _, code = Job:new({
    command = 'gsutil',
    args = {'cp', source, gspath},
    env = vim.env,
  }):sync()
  if code ~= 0 then
    error(string.format('failed to upload %s to %s (%d)', source, gspath, code))
  end

  local host_name = vim.g['imgup#gcloud#host_name']
  return string.format('https://%s/%s/%s', host_name, prefix, name)
end

local M = {}
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
