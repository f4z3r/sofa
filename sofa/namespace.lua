local os = require("os")
local string = require("string")

local log = require("sofa.log")
local utils = require("sofa.utils")

local DEFAULT_NAMESPACE = {
  commands = {},
}

local DEFAULT_COMMAND = {
  interactive = false,
  tags = {},
  parameters = {},
}

local DEFAULT_PARAMETER = {
  choices = {},
  exclusive = false,
}

local namespace = {}

---@class Parameter
---@field name string
---@field prompt string
---@field private default any?
---@field private choices any[]? | string
---@field exclusive boolean
---@field private mapping { [string]: any }? | string
local Parameter = {}

---@param name string
---@param o table?
---@return Parameter
function Parameter:new(name, o)
  o = utils.apply_defaults(o or {}, DEFAULT_PARAMETER)
  o.name = name
  o.prompt = o.prompt or o.name
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
  if self:is_command() then
    error("cannot call get choices for parameter configured with command string", 1)
  end
  local res = {}
  local choices = self.choices or {}
  ---@cast choices any[]
  for _, choice in ipairs(choices) do
    res[#res + 1] = tostring(choice)
  end
  return res
end

---returns whether the parameter was configured with a command
---@return boolean
function Parameter:is_command()
  return type(self.choices) == "string"
end

---get the configured command for this parameter
---@return string
function Parameter:get_command()
  if not self:is_command() then
    error("cannot call get command for parameter configured with literal choices", 1)
  end
  ---@type string
  return self.choices
end

---return the mapped value for the provided choice
---@param key string
---@return string
function Parameter:get_mapped_value(key)
  if type(self.mapping) == "string" then
    local cmd = string.format('echo -ne "%s" | %s', key, utils.escape_quotes(self.mapping))
    local code, out = utils.run(cmd)
    if code ~= 0 or out == nil then
      log:log(string.format("mapping: failed to run command '%s'", cmd))
      os.exit(code)
    end
    return out
  end
  local mapping = self.mapping or {}
  return mapping[key] or key
end

---@class Command
---@field name string
---@field description string?
---@field command string
---@field interactive boolean
---@field tags string[]
---@field private parameters { [string]: Parameter }
local Command = {}

---@param name string
---@param o table
---@return Command
function Command:new(name, o)
  o = utils.apply_defaults(o, DEFAULT_COMMAND)
  o.name = name
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

---return the registered paramter of the given name
---@param name string
---@return Parameter
function Command:get_param(name)
  return self.parameters[name] or Parameter:new(name, {})
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
  utils.apply_defaults(o, DEFAULT_NAMESPACE)
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
    if interactive or (not interactive and not cmd.interactive) then
      commands[name] = cmd
    end
  end
  return commands
end

namespace.Namespace = Namespace

return namespace
