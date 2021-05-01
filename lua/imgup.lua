local M = {}

local Job = require 'plenary.job'
local Matic = require 'imgup.puremagic.puremagic'

M.get_image_url = function()
  return vim.fn['imgup#get_image_url']()
end

local function switch_gcloud_conf(name)
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
    error('failed to list gcloud configurations: ' .. code)
  end

  local conf_active = vim.fn.json_decode(vim.fn.join(result, ''))[1]['name']
  if conf_active == name or conf_active == nil then
    return nil
  end

  _, code = Job:new({
    command = 'gcloud',
    args = {'config', 'configurations', 'activate', name}
  }):sync()
  if code ~= 0 then
    error('failed to acitvate gcloud configuration ' .. name .. ': ' .. code)
  end

  return conf_active
end

M.is_local = function(path)
  return string.find(path, '^https?://') == nil
end

local function download(path)
  local temp = vim.fn.tempname()
  os.execute('curl --output ' .. temp ' ' .. vim.fn.shellescape(path))
  return temp
end

local function guess_name(path, ext)
  return string.gsub(vim.fn.fnamemodify(path, ':t'), '%.[^%.]+$', '', 1) .. ext
end

local function upload(path)
  local mime = Matic.via_path(path)
  if mime == nil then
    error('failed to upload a file ' .. path .. ': failed to guess mime type')
  end

  -- UNDONE: bind base url
  -- UNDONE: rondomize name or the trim extension
  if mime == 'image/png' then
    return 'https://post.kyoh86.dev/image/' .. guess_name(path, '.png')
  elseif mime == 'image/jpeg' then
    return 'https://post.kyoh86.dev/image/' .. guess_name(path, '.jpeg')
  elseif mime == 'image/gif' then
    return 'https://post.kyoh86.dev/image/' .. guess_name(path, '.gif')
  elseif mime == 'image/svg+xml' then
    return 'https://post.kyoh86.dev/image/' .. guess_name(path, '.svg')
  elseif mime == 'image/tiff' then
    return 'https://post.kyoh86.dev/image/' .. guess_name(path, '.tiff')
  elseif mime == 'image/webp' then
    return 'https://post.kyoh86.dev/image/' .. guess_name(path, '.webp')
  end
  error('failed to upload a file ' .. path .. ': not supported mime type (' .. mime .. ')')
end

M.store = function(path)
  if not M.is_local(path) then
    path = download(Path)
  end
  return upload(path)
end

return M
