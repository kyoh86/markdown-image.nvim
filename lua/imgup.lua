local Job = require 'plenary.job'

local M = {}

local function get_image_url()
  return vim.fn['imgup#get_image_url']()
end
M.get_image_url = get_image_url

local function update_image_url(old, new)
  vim.fn['imgup#update_image_url'](old, new)
end

local function download(source)
  local temp = vim.fn.tempname()
  local _, code = Job:new({
    command = 'curl',
    args = {'--output', temp, source},
    env = vim.env,
  }):sync()
  if code ~= 0 then
    error(string.format('failed to download %s (%d)', source, code))
  end
  return temp
end

local function _is_local(source)
  return string.find(source, '^https?://') == nil
end
M._is_local = _is_local -- publish for test

local function deploy(deployer, source)
  local err = deployer.check(source)
  if err ~= nil then
    error(nil)
  end

  if _is_local(source) then
    return deployer.deploy(source, nil)
  else
    temp = download(source)
    repl = deployer.deploy(temp, source)
    os.remove(temp)
    return repl
  end
end

local function replace(deployer)
  -- replace url in the Markdown Image (i.e. "![alternative text](image url)")
  local source = get_image_url()
  if source == '' then
    error("NOT A IMAGE")
  end
  update_image_url(source, deploy(source))
end
M.replace = replace

local function put(deployer)
  local source = vim.fn.getreg(vim.v.register)
  if source == '' then
    return
  end
  vim.cmd('put "![](' .. deploy(deployer, source) .. ')')
end
M.put = put

return M
