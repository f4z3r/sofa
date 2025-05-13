local os = require("os")

if os.getenv("DISPLAY") == nil then
  return require("sofa.pickers.fzf")
else
  return require("sofa.pickers.rofi")
end
