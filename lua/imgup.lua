local M = {}

local Job = require 'plenary.job'
local Matic = require 'imgup.puremagic.puremagic'

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
  -- TODO: use plenary.Job
  os.execute('curl --output ' .. temp ' ' .. vim.fn.shellescape(path))
  return temp
end

local function guess_ext(path)
  local mime = Matic.via_path(path)
  if mime == nil then
    return nil
  end
  if vim.tbl_contains({'image/png', 'image/jpeg', 'image/gif', 'image/tiff', 'image/webp'}, mime) then
    return string.sub(mime, 7)
  end
  return nil
end

local function guess_name(path)
  local ext = guess_ext(path)
  if ext == nil then
    error(string.format('failed to guesss ext for ', path))
  end
  return string.gsub(vim.fn.fnamemodify(path, ':t'), '%.[^%.]+$', '', 1) .. ext
end

local function is_local(path)
  return string.find(path, '^https?://') == nil
end
M.is_local = is_local -- for test

local function store(path)
  if not is_local(path) then
    path = download(path)
  end
  local name = guess_name(path)

  local errors = {}
  for _, module_name in ipairs({'imgup.gcloud'}) do
    local module = require(module_name)
    local loaded, err = module.is_valid()
    if loaded then
      return module.upload(path, name)
    end
    table.insert(errors, string.format('%s: %s', module_name, err))
  end

  error("there's no valid module; " .. table.concat(errors, '; '))
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
