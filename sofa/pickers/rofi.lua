local string = require("string")
local table = require("table")

local utils = require("sofa.utils")

local rofi = {}

local NUL_SEPARATOR = "\0"
local FIELD_SEPARATOR = "\x1f"
local COMMAND_SEPARATOR = " > "

---@class Rofi
local Rofi = {}

---create a new Rofi picker based on configuration
---@param _config table
---@return Rofi
function Rofi:new(_config)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Rofi:_pick(prompt, choices, options)
  local content = table.concat(choices, "\n")
  local filename, delete = utils.write_to_tmp(content)
  prompt = utils.escape_quotes(prompt)
  local cmd = string.format("rofi -dmenu -input '%s' -p '%s'", filename, prompt)
  local cmd_parts = { cmd }
  if options.mesg then
    local mesg = utils.escape_quotes(options.mesg)
    cmd_parts[#cmd_parts + 1] = string.format("-mesg '%s'", mesg)
  end
  if options.case_insensitive then
    cmd_parts[#cmd_parts + 1] = "-i"
  end
  if options.no_custom then
    cmd_parts[#cmd_parts + 1] = "-no-custom"
  end
  if options.only_match then
    cmd_parts[#cmd_parts + 1] = "-no-custom"
  end
  if options.markup then
    cmd_parts[#cmd_parts + 1] = "-markup-rows"
  end
  if options.default then
    local default = utils.escape_quotes(options.default)
    cmd_parts[#cmd_parts + 1] = string.format("-select '%s'", default)
  end
  local command = table.concat(cmd_parts, " ")
  local response = utils.run(command)
  delete()
  return utils.trim_whitespace(response)
end

---add options to a row
---@param row string
---@param options { [string]: any }
---@return string
function Rofi:_add_row_options(row, options)
  local res = {}
  for k, v in pairs(options) do
    res[#res + 1] = k .. FIELD_SEPARATOR .. tostring(v)
  end
  return row .. NUL_SEPARATOR .. table.concat(res, FIELD_SEPARATOR)
end

---return the command that the user picked
---@param namespaces { [string]: Namespace }
---@param interactive boolean
---@return Command
function Rofi:pick_command(namespaces, interactive)
  local choices = {}
  for ns_name, ns in pairs(namespaces) do
    for cmd_name, cmd in pairs(ns:get_commands(interactive)) do
      local tags = table.concat(cmd:get_tags(), " ")
      local options = {}
      if tags then
        options.meta = tags
      end
      local choice = string.format("%s%s%s", ns_name, COMMAND_SEPARATOR, cmd_name)
      if cmd.description then
        choice = choice .. string.format(' <span size="small"><i>(%s)</i></span>', cmd.description)
      end
      choices[#choices + 1] = self:_add_row_options(choice, options)
    end
  end
  local pick = self:_pick("Command", choices, { only_match = true, case_insensitive = true, markup = true })
  local namespace, command = pick:match("^(.+)" .. COMMAND_SEPARATOR .. "(.+) <span")
  if not namespace then
    namespace, command = pick:match("^(.+)" .. COMMAND_SEPARATOR .. "(.+)$")
  end
  return namespaces[namespace]:get_commands(interactive)[command]
end

---returns the value of a parameter
---@param parameter Parameter
---@param command string
---@return string
function Rofi:pick_parameter(parameter, command)
  local prompt = parameter.prompt or parameter.name
  local choices = parameter:get_choices()
  local markup_choices = {}
  for _, choice in ipairs(choices) do
    local substitute = parameter:get_mapped_value(choice)
    if substitute == choice then
      markup_choices[#markup_choices+1] = choice
    else
      markup_choices[#markup_choices+1] = string.format('%s <span size="small"><i>(%s)</i></span>', choice, substitute)
    end
  end
  command = command:gsub(
    string.format("{{%%s*%s%%s*}}", parameter.name),
    string.format('<span foreground="red">{{ %s }}</span>', parameter.name)
  )
  local pick = self:_pick(prompt, markup_choices, {
    markup = true,
    no_custom = parameter:get_exclusive(),
    default = parameter:get_default(),
    case_insensitive = true,
    mesg = "Command: " .. command,
  })
  local choice = pick:match("^(.+) <span") or pick
  local default = parameter:get_default()
  if choice == "" and default then
    choice = default
  end
  return parameter:get_mapped_value(pick)
end

rofi.Rofi = Rofi

return rofi
