local io = require("io")

local yaml = require("lyaml")

local namespace = require("sofa.namespace")
local utils = require("sofa.utils")

local DEFAULT_CONFIG_PATH = "~/.config/sofa/config.yaml"
local CONFIG_ENV_VAR = "SOFA_CONFIG"

local DEFAULT_CONFIG = {
  config = {
    shell = "bash",
    picker = "rofi",
    pickers = {
      fzf = {
        default_options = "--no-multi --cycle --ansi",
        no_color = false,
      },
    },
  },
}

local function get_default_env(name, default)
  local val = os.getenv(name)
  if val == nil then
    return default
  end
  return val
end

local function expand_home(path)
  local home = assert(os.getenv("HOME"))
  return path:gsub("~", home)
end

local function read_config()
  local config_file = expand_home(get_default_env(CONFIG_ENV_VAR, DEFAULT_CONFIG_PATH))
  local fh = assert(io.open(config_file, "r"))
  local content = fh:read("*a")
  fh:close()
  local conf = yaml.load(content)
  local namespaces = conf.namespaces
  conf.namespaces = {}
  for name, cmds in pairs(namespaces) do
    conf.namespaces[name] = namespace.Namespace:new(name, cmds)
  end
  -- apply default configuration
  conf.config = utils.apply_defaults(conf.config, DEFAULT_CONFIG.config)
  return conf
end

---@class Config
---@field namespaces { [string]: Namespace }
---@field config table
return read_config()
