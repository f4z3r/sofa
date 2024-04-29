require("compat53")

local io = require("io")

local arguments = require("sofa.arguments")
local config = require("sofa.config")
local engine = require("sofa.engine")
local rofi = require("sofa.pickers.rofi")

local function main()
  -- TODO: ensure what happens if config is empty
  local cli_args = arguments.parse()
  local picker = rofi.Rofi:new(config.config)
  local interactive = cli_args.interactive or false
  local cmd = picker:pick_command(config.namespaces, interactive)
  local args = cmd:get_args()
  local params = {}
  for _, argument in ipairs(args) do
    local parameter = cmd:get_param(argument)
    local command = cmd:substitute(params)
    params[argument] = picker:pick_parameter(parameter, command)
  end

  local command = cmd:substitute(params)
  if cli_args.interactive then
    io.stdout:write(command)
  else
    local exec = engine.ExecutionEngine:new(config.config)
    exec:run(command)
  end
end

main()
