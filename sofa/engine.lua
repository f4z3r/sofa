local string = require("string")
local utils = require("sofa.utils")

local engine = {}

---@class ExecutionEngine
local ExecutionEngine = {}

---create a new execution engine based on the configuration
---@param _config table
---@return ExecutionEngine
function ExecutionEngine:new(_config)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

---run a command using the execution engine
---@param command string
function ExecutionEngine:run(command)
  -- TODO: make shell configurable
  local cmd = string.format("bash -c '%s'", utils.escape_quotes(command))
  os.execute(cmd)
end

engine.ExecutionEngine = ExecutionEngine

return engine
