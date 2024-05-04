local os = require("os")
local string = require("string")

local utils = require("sofa.utils")

---@class Logger
---@field private filename string
local Logger = {}

---create a new logger
---@return Logger
function Logger:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

---set the log file to log to
---@param file string
function Logger:set_file(file)
  self.filename = utils.expand_home(file)
  local directory = string.match(self.filename, "^(.+)/")
  os.execute(string.format("mkdir -p %s", directory))
end

---log something
---@param entry string
function Logger:log(entry)
  local timestamp = os.date("%F %T")
  local fh = assert(io.open(self.filename, "a+"))
  fh:write(string.format("%s %s\n", timestamp, entry))
  fh:close()
end

return Logger:new()
