local string = require("string")

local utils = require("sofa.utils")

local namespace = {}

---@class Parameter
---@field name string
---@field prompt string
---@field private default any?
---@field private choices any[]?
---@field private exclusive boolean?
---@field private mapping { [string]: any }?
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

---return default set for this parameter, if any
---@return string|nil
function Parameter:get_default()
  return self.default and tostring(self.default) or nil
end

---return choices set of this parameter
---@return string[]
function Parameter:get_choices()
  local res = {}
  for _, choice in ipairs(self.choices or {}) do
    res[#res + 1] = tostring(choice)
  end
  return res
end

---return whether the exclusive flag was set for this parameter
---@return boolean
function Parameter:get_exclusive()
  return self.exclusive or false
end

---return the mapped value for the provided choice
---@param key string
---@return string
function Parameter:get_mapped_value(key)
  local mapping = self.mapping or {}
  return mapping[key] or key
end

---@class Command
---@field name string
---@field description string?
---@field command string
---@field private interactive boolean
---@field private tags string[]?
---@field private parameters { [string]: Parameter }
local Command = {}

---@param name string
---@param o table
---@return Command
function Command:new(name, o)
  o.name = name
  o.tags = o.tags or {} -- set default tags
  local params = o.parameters
  o.parameters = {}
  for p_name, param in pairs(params or {}) do
    o.parameters[p_name] = Parameter:new(p_name, param)
  end
  setmetatable(o, self)
  self.__index = self
  return o
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
  return utils.deduplicate(res)
end

---return the tags for that command
---@return string[]
function Command:get_tags()
  return self.tags or {}
end

---return the registered paramter of the given name
---@param name string
---@return Parameter
function Command:get_param(name)
  return self.parameters[name] or Parameter:new(name, {})
end

---return whether the command should be run in interactive mode
---@return boolean
function Command:is_interactive()
  return self.interactive or false
end

---substitute the parameters passed into the command
---@param params { [string]: string }
---@return string
function Command:substitute(params)
  local res = self.command
  for param, value in pairs(params) do
    local pattern = string.format("{{%%s*%s%%s*}}", param)
    res = res:gsub(pattern, value)
  end
  return res
end

---@class Namespace
---@field name string
---@field private commands { [string]: Command }
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

---return commands based on whether they are interactive
---@param interactive boolean
---@return { [string]: Command }
function Namespace:get_commands(interactive)
  local commands = {}
  for name, cmd in pairs(self.commands) do
    if not interactive or (interactive and cmd:is_interactive()) then
      commands[name] = cmd
    end
  end
  return commands
end

namespace.Namespace = Namespace

return namespace
