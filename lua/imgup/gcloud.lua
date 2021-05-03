local Job = require 'plenary.job'
local nanoid = require('nanoid')

local Deployer = {}

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

local function upload(host, bucket, prefix, path)
  local name = nanoid()

  if prefix ~= nil and prefix ~= '' then
    name = string.gsub(prefix, '^/+|/+$', '') .. '/' .. name
  end

  local bucket_name = bucket
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

  return string.format('https://%s/%s', host, name)
end

function Deployer.check(self, origin)
  -- check whether the origin is supported or not
  local url = require('resty.url').parse(origin)
  if url.host == self.host then
    error("it's already deployed file")
  end
end

function Deployer.deploy(self, path, original)
  -- deploy path and get URL for deployed resource
  local prev_conf = switch_conf(self.config)
  local success, ret = pcall(upload, self.host, self.bucket, self.prefix, path)
  if prev_conf then
    switch_conf(prev_conf)
  end
  if success then
    return ret
  else
    error(ret)
  end
end

function Deployer.new(host, config, bucket, prefix)
  local obj = {
    host = host,
    config = config,
    bucket = bucket,
    prefix = prefix,
  }
  if host == nil or host == '' then
    error("empty host name")
  end
  if config == nil or config == '' then
    error("empty config name")
  end
  if bucket == nil or bucket == '' then
    error("empty bucket name")
  end
  return setmetatable(obj, {__index = Deployer})
end

return Deployer
