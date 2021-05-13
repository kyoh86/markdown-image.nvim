local Job = require 'plenary.job'

local Deployer = {}

local function upload(token, path)
  local cp = Job:new({
    command = 'curl',
    args = {
      '-i',
      '-H', 'Accept: application/json',
      'https://upload.gyazo.com/api/upload',
      '-F', string.format('access_token=%s', token),
      '-F', string.format('imagedata=@%s', path),
    },
    enable_recording = true,
  })
  result, code = cp:sync()
  if code ~= 0 then
    local errors = cp:stderr_result()
    error(string.format('failed to upload %s: %s (%d)', path, table.concat(errors, '\n'), code))
  end

  local body = {}
  local status = 0
  for i, line in ipairs(result) do
    line = string.gsub(line, '^%s+|%s+$', '')
    status_candidate = string.match(line, '^HTTP/[%d%.]+ (%d+)')
    if status_candidate ~= nil then
      status = tonumber(status_candidate)
    end
    if line == '' then
      body = {unpack(result, i)}
      break
    end
  end

  if status ~= 200 then
    error(string.format('failed to upload %s to %s: http %d\n%s', path, status, vim.fn.join(body, '\n')))
  end

  local response_object = vim.fn.json_decode(vim.fn.join(body, ''))
  local image_url = response_object.url

  if image_url == nil or image_url == '' then
    error(string.format('failed to get upload image:\n%s', vim.fn.join(body, '\n')))
  end

  return image_url
end

function Deployer.check(self, origin)
  -- check whether the origin is supported or not
  local match = string.match(origin, '^https://i%.gyazo%.com/')
  if match ~= nil then
    error(string.format("%s is already deployed on %s", self.host, origin))
  end
end

function Deployer.deploy(self, path, original)
  return upload(self.token, path)
end

function Deployer.new(token, prefix)
  local obj = {
    token = token,
  }
  if token == nil or token == '' then
    error("empty access token")
  end
  return setmetatable(obj, {__index = Deployer})
end

return Deployer
