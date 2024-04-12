local argparse = require("argparse")

local arguments = {}

function arguments.parse()
  local parser = argparse()
    :name("sofa")
    :description("A command execution engine powered by rofi.")
    :epilog("For more information see: https://github.com/f4z3r/sofa")
    :add_complete()

  parser:flag("-i --interactive", "Whether to get interactive commands.")

  return parser:parse()
end

return arguments
