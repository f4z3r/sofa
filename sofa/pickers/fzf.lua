local os = require("os")

local text = require("luatext")

local pickers = require("sofa.pickers")
local utils = require("sofa.utils")

local fzf = {}

local COMMAND_SEPARATOR = " | "
local ANSI_GRAY = 244

---@class Fzf: AbstractPicker
---@field private default_options string
---@field private no_color boolean
local Fzf = pickers.AbstractPicker:new({})

---create a new Fzf picker based on configuration
---@param config table
---@return Fzf
function Fzf:new(config)
  local o = config.pickers.fzf
  setmetatable(o, self)
  self.__index = self
  return o
end

---colorize a string
---@param str string
---@param color number
---@return string
function Fzf:colorize(str, color)
  if self.no_color then
    return str
  end
  return text.Text:new(str):fg(color):render()
end

local function add_options(cmd, options)
  local cmd_parts = { cmd }
  if options.header then
    local header = utils.escape_quotes(options.header)
    cmd_parts[#cmd_parts + 1] = string.format("--header='%s'", header)
  end
  return table.concat(cmd_parts, " ")
end

---parse an fzf response string into its output value
---@param response string
---@return string the response
---@return boolean whether the response was a new entry not listed in choices
function fzf._parse_response(response)
  local _, pick = string.match(response, "^([^\n]-)\n([^\n]+)")
  if pick ~= nil and pick ~= "" then
    return utils.trim_whitespace(pick), false
  elseif string.match(response, "^\n([^\n]+)") then
    return utils.trim_whitespace(response), false
  end
  return utils.trim_whitespace(response), true
end

---return a pick from fzf
---@param prompt string
---@param choices_cmd string
---@param options { [string]: any }
---@return string the response
---@return boolean whether the response was a new entry not listed in choices
function Fzf:_pick_from_cmd(prompt, choices_cmd, options)
  prompt = utils.escape_quotes(prompt)
  prompt = prompt .. "> "
  local cmd = string.format("%s | fzf --print-query %s --prompt='%s'", choices_cmd, self.default_options, prompt)
  local command = add_options(cmd, options)
  local status_code, response = utils.run(command)
  if status_code > 1 then
    os.exit(1)
  end
  return fzf._parse_response(response or "")
end

---return a pick from fzf
---@param prompt string
---@param choices string[]
---@param options { [string]: any }
---@return string the response
---@return boolean whether the response was a new entry not listed in choices
function Fzf:_pick(prompt, choices, options)
  local content = table.concat(choices, "\n")
  local command = string.format('echo -ne "%s"', content)
  return self:_pick_from_cmd(prompt, command, options)
end

---return the command that the user picked
---@param namespaces { [string]: Namespace }
---@param interactive boolean
---@return Command
function Fzf:pick_command(namespaces, interactive)
  local sep = self:colorize(COMMAND_SEPARATOR, text.Color.Magenta)
  local choices = {}
  for ns_name, ns in pairs(namespaces) do
    for cmd_name, cmd in pairs(ns:get_commands(interactive)) do
      local choice = string.format("%-20s%s%s", ns_name, sep, cmd_name)
      if cmd.description then
        local desc = self:colorize(string.format("(%s)", cmd.description), text.Color.Cyan)
        choice = string.format("%s %s", choice, desc)
      end
      local tags = table.concat(cmd.tags, ", ")
      if tags ~= "" then
        tags = self:colorize(string.format("[%s]", tags), ANSI_GRAY)
        choice = string.format("%s %s", choice, tags)
      end
      choices[#choices + 1] = choice
    end
  end
  local pick, custom = self:_pick("Command", choices, {})
  if custom then
    os.exit(1)
  end
  local namespace, command = pick:match("^(%S+)%s*" .. COMMAND_SEPARATOR .. "(.+) %(")
  if not namespace then
    namespace, command = pick:match("^(%S+)%s*" .. COMMAND_SEPARATOR .. "(.+) %[")
  end
  if not namespace then
    namespace, command = pick:match("^(%S+)%s*" .. COMMAND_SEPARATOR .. "(.+)$")
  end
  return namespaces[namespace]:get_commands(interactive)[command]
end

---return a templated string for a parameter choice
---@param choice string
---@param sub string
---@return string
function Fzf:_template_param_choice(choice, sub)
  if sub == choice then
    return choice
  end
  return string.format("%s (%s)", choice, self:colorize(sub, text.Color.Green))
end

---returns markup defined choices for a parmaters based on `choices` field. The default, if any, will always be the
---first value in the returned array
---@param parameter Parameter
---@return string[]
function Fzf:_get_choices_for_param(parameter)
  local choices = parameter:get_choices()
  local default = parameter:get_default()
  local markup_choices = {}
  for _, choice in ipairs(choices) do
    local substitute = parameter:get_mapped_value(choice)
    local templated_choice = self:_template_param_choice(choice, substitute)
    if choice == default then
      table.insert(markup_choices, 1, templated_choice)
    else
      markup_choices[#markup_choices + 1] = templated_choice
    end
  end
  return markup_choices
end

---return the value for a pick given a parameter
---@param parameter Parameter
---@param pick string
---@return string
function Fzf:_get_value_for_pick(parameter, pick)
  local default = parameter:get_default()
  local choice = pick:match("^(.+) %(") or pick
  if choice == "" and default then
    choice = default
  end
  return parameter:get_mapped_value(choice)
end

---returns the value of a parameter
---@param parameter Parameter
---@param command string
---@return string
function Fzf:pick_parameter(parameter, command)
  local sub = string.format("{{ %s }}", parameter.name)
  local default = parameter:get_default()
  if default then
    sub = default
  end
  if self.no_color then
    sub = string.format(">%s<", sub)
  else
    sub = self:colorize(sub, text.Color.Red)
  end
  command = command:gsub(string.format("{{%%s*%s%%s*}}", parameter.name), sub)
  local options = {
    header = "Command: " .. command,
  }
  local pick, custom = nil, false
  local prompt = parameter.prompt
  if parameter:is_command() then
    pick, custom = self:_pick_from_cmd(prompt, parameter:get_command(), options)
  else
    local choices = self:_get_choices_for_param(parameter)
    pick, custom = self:_pick(prompt, choices, options)
  end
  if custom and parameter.exclusive then
    os.exit(1)
  end
  if custom and pick == "" then
    pick = default
  end
  return self:_get_value_for_pick(parameter, pick)
end

fzf.Fzf = Fzf

---builder
function fzf.new(config)
  return Fzf:new(config)
end

return fzf
