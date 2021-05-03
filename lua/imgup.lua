local Job = require 'plenary.job'

local M = {}

local function get_image_url()
  local res = vim.fn['imgup#get_image_url']()
  if #res == 0 then
    return nil
  end
  return res[1], res[2], res[3], res[4]
end
M.get_image_url = get_image_url

local function update_image_url(old, new)
  vim.fn['imgup#update_image_url'](old, new)
end

local function download(path)
  local temp = vim.fn.tempname()
  local _, code = Job:new({
    command = 'curl',
    args = {'--output', temp, path},
    env = vim.env,
  }):sync()
  if code ~= 0 then
    error(string.format('failed to download %s (%d)', path, code))
  end
  return temp
end

local function is_local(path)
  return string.find(path, '^https?://') == nil
end
M.is_local = is_local -- for test

local deploy_module = require('imgup.gcloud') -- UNDONE: make it configureable

local function store(path)
  deploy_module.ready()

  if deploy_module.has(path) then
    error("it's already deployed file")
  end

  if is_local(path) then
    return deploy_module.deploy(path, nil)
  else
    temp = download(path)
    repl = deploy_module.deploy(temp, path)
    os.remove(temp)
    return repl
  end
end

local function replace()
  -- replace url in the Markdown Image (i.e. "![alternative text](image url)")
  local source, scol, ecol, line = get_image_url()
  if source == nil then
    error("NOT A IMAGE")
  end

  local url = store(source)
  update_image_url(source, url)
end
M.replace = replace

local function put(source)
  if not vim.fn.filereadable(source) then
    error(string.format("NOT A FILE: %s", source))
  end
  local url = store(source)
  vim.cmd('put "![](' .. source .. ')')
end
M.put = put

return M
