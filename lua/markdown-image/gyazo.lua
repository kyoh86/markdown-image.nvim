local Job = require "plenary.job"

local Deployer = {}

function Deployer.check(self, origin)
  -- check whether the origin is supported or not
  local match = string.match(origin, "^https?://([^/:]+)")
  if match == self.host then
    error(string.format("%s is already deployed on %s", origin, self.host))
  end
end

function Deployer.deploy(self, path, original)
  local result, code =
    Job:new(
    {
      command = "curl",
      args = {
        "--silent",
        "-XPOST",
        "-F",
        "access_token=" .. self.token,
        "-F",
        "metadata_is_public=false",
        "-F",
        "app=markdown-image.nvim",
        "-F",
        "imagedata=@" .. path,
        "https://upload.gyazo.com/api/upload"
      }
    }
  ):sync()
  if code ~= 0 then
    error(string.format("failed to upload %s (%d)", path, code))
  end
  return vim.fn.json_decode(vim.fn.join(result, ""))["url"]
end

function Deployer.new(token)
  local obj = {
    host = "i.gyazo.com", -- Gyazo teams has not supported by API yet.
    token = token
  }
  if token == nil or token == "" then
    error("empty token")
  end
  return setmetatable(obj, {__index = Deployer})
end

return Deployer
