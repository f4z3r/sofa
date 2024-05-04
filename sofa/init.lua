require("compat53")

local io = require("io")

local arguments = require("sofa.arguments")
local config = require("sofa.config")
local engine = require("sofa.engine")
local log = require("sofa.log")

local function main()
  log:set_file(config.config.log)
  local cli_args = arguments.parse()
  local mod = require("sofa.pickers." .. config.config.picker)
  local picker = mod.new(config.config)
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
