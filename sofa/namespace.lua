local namespace = {}

---@class Parameter
---@field private name string
---@field private description string
---@field private default any?
---@field private choices any[]
---@field private exclusive boolean
---@field private mapping { [string]: any }
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

---return the parameter description
---@return string
function Parameter:desc()
  return self.description or self.name
end

function Parameter:get_default()
  return self.default and tostring(self.default) or nil
end

function Parameter:get_choices()
  -- TODO add default to choices
  local res = {}
  for _, choice in ipairs(self.choices or {}) do
    res[#res + 1] = tostring(choice)
  end
  return res
end

function Parameter:get_exclusive()
  return self.exclusive or false
end

function Parameter:get_mapped_values(key)
  return self.mapping[key] or key
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

---return the arguments by name stored within a command
---@return string[]
function Command:get_args()
  local command = self.command
  local res = {}
  local args = command:gmatch("{{%s*(%S+)%s*}}")
  for arg in args do
    res[#res + 1] = arg
  end
  return res
end

function Command:get_param(name)
  return self.parameters[name] or Parameter:new(name, {})
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

---return the name of a command by its description
---@param desc string
---@return string?
function Namespace:get_command_by_desc(desc)
  for name, cmd in pairs(self.commands) do
    if cmd:desc() == desc then
      return name
    end
  end
  return nil
end

namespace.Namespace = Namespace

return namespace
