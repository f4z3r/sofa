local string = require("string")
local utils = require("sofa.utils")

local engine = {}

---@class ExecutionEngine
---@field private shell string
local ExecutionEngine = {}

---create a new execution engine based on the configuration
---@param config table
---@return ExecutionEngine
function ExecutionEngine:new(config)
  local o = {}
  o.shell = config.shell
  setmetatable(o, self)
  self.__index = self
  return o
end

---run a command using the execution engine
---@param command string
function ExecutionEngine:run(command)
  local cmd = string.format("%s -c '%s'", self.shell, utils.escape_quotes(command))
  os.execute(cmd)
end

engine.ExecutionEngine = ExecutionEngine

return engine
