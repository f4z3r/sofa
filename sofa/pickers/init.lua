local pickers = {}

---@class AbstractPicker
local AbstractPicker = {}

---create a new Picker based on configuration
---@param config table
---@return AbstractPicker
function AbstractPicker:new(config)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

---return the command that the user picked
---@param namespaces { [string]: Namespace }
---@param interactive boolean
---@return Command
function AbstractPicker:pick_command(namespaces, interactive)
  error("not implemented", 1)
end

---returns the value of a parameter
---@param parameter Parameter
---@param command string
---@return string
function AbstractPicker:pick_parameter(parameter, command)
  error("not implemented", 1)
end

pickers.AbstractPicker = AbstractPicker

return pickers
