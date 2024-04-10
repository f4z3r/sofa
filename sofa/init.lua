local os = require("os")
local string = require("string")

local rofi = require("sofa.rofi")

local rofi_data = os.getenv("ROFI_DATA")

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
    local command = config.CONFIG.namespaces[ns].commands[cmd].command
    rofi.set_data({
      namespace = ns,
      command = cmd,
    })
    os.execute(string.match("bash -c '%s' > /tmp/sofa", command))
  end
end

return sofa
