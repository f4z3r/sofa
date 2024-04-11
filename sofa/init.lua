local config = require("sofa.config")
local engine = require("sofa.engine")
local rofi = require("sofa.pickers.rofi")

local function main()
  -- TODO: ensure what happens if config is empty
  local picker = rofi.Rofi:new(config.config)
  local cmd = picker:pick_command(config.namespaces)
  local arguments = cmd:get_args()
  local params = {}
  for _, argument in ipairs(arguments) do
    local parameter = cmd:get_param(argument)
    local command = cmd:substitute(params)
    params[argument] = picker:pick_parameter(parameter, command)
  end

  local command = cmd:substitute(params)
  local exec = engine.ExecutionEngine:new(config.config)
  exec:run(command)
end

main()
