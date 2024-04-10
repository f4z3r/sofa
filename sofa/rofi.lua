local table = require("table")

local config = require("sofa.config")

local rofi = {}

local NUL_SEPARATOR = "\0"
local FIELD_SEPARATOR = "\x1f"
local COMMAND_SEPARATOR = " > "

---add options to a row
---@param row string
---@param opts { [string]: any }
---@return string
local function add_row_options(row, opts)
  local res = {}
  for k, v in pairs(opts) do
    res[#res + 1] = k .. FIELD_SEPARATOR .. tostring(v)
  end
  return row .. NUL_SEPARATOR .. table.concat(res, FIELD_SEPARATOR)
end

function rofi.set_prompt(prompt)
  print(NUL_SEPARATOR .. "prompt" .. FIELD_SEPARATOR .. prompt)
end

function rofi.set_exclusive()
  print(NUL_SEPARATOR .. "no-custom" .. FIELD_SEPARATOR .. "true")
end

function rofi.set_data(data)
  local res = {}
  for k, v in pairs(data) do
    res[#res + 1] = k .. "=" .. tostring(v)
  end
  -- TODO improve this
  print(NUL_SEPARATOR .. "data" .. FIELD_SEPARATOR .. table.concat(res, ";"))
end

function rofi.command_choices()
  for ns_name, ns in pairs(config.CONFIG.namespaces) do
    for _, cmd in pairs(ns.commands) do
      local tags = table.concat(cmd.tags, " ")
      local options = {}
      if tags then
        options.tags = tags
      end
      print(add_row_options(ns_name .. COMMAND_SEPARATOR .. cmd:desc(), options))
    end
  end
end

function rofi.split_command_choice(choice)
  local ns, cmd = choice:match("^(.*)"..COMMAND_SEPARATOR.."(.*)$")
  return ns, cmd
end

return rofi
