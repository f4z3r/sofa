local io = require("io")
local string = require("string")

local yaml = require("lyaml")

local namespace = require("sofa.namespace")

local DEFAULT_CONFIG_PATH = "~/.config/sofa/config.yaml"
local CONFIG_ENV_VAR = "SOFA_CONFIG"

local config = {}

config.PROG = "sofa"

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

local config_file = expand_home(get_default_env(CONFIG_ENV_VAR, DEFAULT_CONFIG_PATH))

config.ENV = string.format("%s=%s", CONFIG_ENV_VAR, config_file)

local function read_config()
  local fh = assert(io.open(config_file, "r"))
  local content = fh:read("*a")
  fh:close()
  local conf = yaml.load(content)
  local namespaces = conf.namespaces
  conf.namespaces = {}
  for name, cmds in pairs(namespaces) do
    conf.namespaces[name] = namespace.Namespace:new(name, cmds)
  end
  return conf
end

---@class Config
---@field namespaces { [string]: Namespace }
---@field config table
config.CONFIG = read_config()

return config
