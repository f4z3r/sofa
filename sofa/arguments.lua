local argparse = require("argparse")

local arguments = {}

function arguments.parse()
  local parser = argparse()
    :name("sofa")
    :description("A command execution engine powered by rofi.")
    :epilog([[The configuration is set at ~/.config/sofa/config.yaml, and its location can be
overwritten using the SOFA_CONFIG environment variable.

For more information see: https://github.com/f4z3r/sofa]])
    :add_complete()

  parser:flag("-i --interactive", "Whether to get interactive commands.")

  return parser:parse()
end

return arguments
