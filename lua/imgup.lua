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

local function is_local(path)
  return string.find(path, '^https?://') == nil
end
M.is_local = is_local

local function download(path)
  local temp = vim.fn.tempname()
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

local function store(path)
  if not is_local(path) then
    path = download(path)
  end
  local name = guess_name(path)
  return require('imgup.gcloud').upload(path, name)
end
M.store = store

local function replace()
  -- replace url in the Markdown Image (i.e. "![alternative text](image url)")
  local source, scol, ecol, line = get_image_url()
  if url == nil then
    return
  end

  -- TODO: upload
  -- TODO: replace ![...](source =wxh) and [](source)
end
M.replace = replace

local function paste()
  -- upload a path in the register and put Markdown Image (i.e. "![alternative text](image url)")
  -- TODO: upload
  -- TODO: paste img link
  -- seealso: https://stackoverflow.com/questions/65429368/paste-path-in-clipboard-modified-to-be-relative-to-current-buffer-in-vim
end

return M
