local os = require("os")

local rofi = require("sofa.rofi")

local rofi_data = os.getenv("ROFI_DATA")
-- ROFI_INFO? for param name?

local sofa = {}

function sofa.run(params)
  if #params == 0 then  -- initial call
    rofi.set_prompt("Command")
    rofi.set_exclusive()
    rofi.command_choices()
  elseif not rofi_data then -- call with command
    local choice = params[1]
    local ns, cmd = rofi.split_command_choice(choice)
    local config = require("sofa.config")
    -- find command with description
    local cmd_name = config.CONFIG.namespaces[ns]:get_command_by_desc(cmd)
    local command = config.CONFIG.namespaces[ns].commands[cmd_name]
    rofi.set_data({
      namespace = ns,
      command = cmd,
    })
    local args = command:get_args()
    if #args == 0 then
      -- execute command
    end
    local arg = args[1]
    local param = command:get_param(arg)
    rofi.set_prompt(param:desc())
    rofi.choose_param(param)
  else
    local data = rofi.get_data(rofi_data)
  end
end

return sofa
