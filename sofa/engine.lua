local string = require("string")
local utils = require("sofa.utils")

local engine = {}

---@class ExecutionEngine
local ExecutionEngine = {}

function ExecutionEngine:new(_config)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ExecutionEngine:run(command)
  -- TODO: make shell configurable
  local cmd = string.format("bash -c '%s'", utils.escape_quotes(command))
  os.execute(cmd)
end

engine.ExecutionEngine = ExecutionEngine

return engine
