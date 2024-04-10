local namespace = {}

---@class Parameter
local Parameter = {}

---@param name string
---@param o table?
---@return Parameter
function Parameter:new(name, o)
  o = o or {}
  o.name = name
  setmetatable(o, self)
  self.__index = self
  return o
end

---@class Command
---@field private name string
---@field private description string
---@field command string
---@field tags string[]
---@field private parameters { [string]: Parameter }
local Command = {}

---@param name string
---@param o table
---@return Command
function Command:new(name, o)
  o.name = name
  o.tags = o.tags or {} -- set default tags
  local params = o.parameters
  for p_name, param in pairs(params) do
    o.parameters[p_name] = Parameter:new(p_name, param)
  end
  setmetatable(o, self)
  self.__index = self
  return o
end

---return the command description
---@return string
function Command:desc()
  return self.description or self.name
end

---@class Namespace
---@field name string
---@field commands { [string]: Command }
local Namespace = {}

---@param name string
---@param o table
---@return Namespace
function Namespace:new(name, o)
  o.name = name
  local cmds = o.commands
  for cmd_name, command in pairs(cmds) do
    o.commands[cmd_name] = Command:new(cmd_name, command)
  end
  setmetatable(o, self)
  self.__index = self
  return o
end

namespace.Namespace = Namespace

return namespace
