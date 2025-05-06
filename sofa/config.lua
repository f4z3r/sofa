-- NOTE: config.lua should not use log.lua as the logger is initialized only after loading the config

local io = require("io")
local string = require("string")

local yaml = require("lyaml")

local namespace = require("sofa.namespace")
local utils = require("sofa.utils")

local DEFAULT_CONFIG_PATH = "~/.config/sofa/config.yaml"
local CONFIG_ENV_VAR = "SOFA_CONFIG"

local DEFAULT_CONFIG = {
  namespaces = {
    wifi = {
      commands = {
        connect = {
          command = "nmcli d wifi connect '{{ network }}'",
          description = "Connect to a favourite wifi network.",
          interactive = false,
          tags = {
            "network",
          },
          parameters = {
            network = {
              prompt = "Choose a network",
              exclusive = true,
              choices = "nmcli --colors no -g ssid d wifi list",
            },
          },
        },
      },
    },
    bookmarks = {
      commands = {
        github = {
          command = "xdg-open 'https://github.com/{{ user }}/{{ project }}'",
          description = "Open a GitHub project",
          tags = {
            "browser",
          },
          parameters = {
            user = {
              default = "f4z3r",
              prompt = "Choose user",
            },
            project = {
              prompt = "Choose project",
            },
          },
        },
        nixos = {
          command = "xdg-open 'https://search.nixos.org/packages?channel={{ channel }}'",
          description = "Open NixOS packages and versions",
          tags = {
            "browser",
          },
          parameters = {
            channel = {
              default = "unstable",
              prompt = "Choose channel",
              choices = {
                "unstable",
                "23.11",
              },
            },
          },
        },
      },
    },
    docker = {
      commands = {
        ["prune-containers"] = {
          command = "docker container list -a | perl -lane 'print @F[0] if ($_ =~ /Exited/ and $_ !~ /k3d/)' | xargs -r docker rm",
          description = "Delete all exited containers",
          interactive = true,
          tags = {
            "local",
            "clean",
          },
        },
        ["prune-images"] = {
          command = "docker images | tail -n+2 | perl -lane 'print @F[2] if @F[1] =~ /<none>/' | xargs -r docker rmi",
          description = "Delete all container images missing a tag",
          interactive = true,
          tags = {
            "local",
            "clean",
          },
        },
      },
    },
  },
  config = {
    log = "~/.local/state/sofa/sofa.log",
    shell = "bash",
    picker = "rofi",
    pickers = {
      fzf = {
        default_options = "--no-multi --cycle --ansi",
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

local function write_default_config(filename)
  os.execute(string.format("mkdir -p $(dirname %s)", filename))
  local fh = io.open(filename, "w")
  if fh == nil then
    io.stderr:write(string.format("ERROR - '%s': cannot open file to write default configuration\n", filename))
  else
    fh:write(yaml.dump({ DEFAULT_CONFIG }))
    fh:close()
  end
end

local function parse_config(config)
  local res = { namespaces = {} }
  for name, cmds in pairs(config.namespaces) do
    res.namespaces[name] = namespace.Namespace:new(name, cmds)
  end
  -- apply default configuration
  res.config = utils.apply_defaults(config.config, DEFAULT_CONFIG.config)
  return res
end

local function read_config()
  local config_file = utils.expand_home(get_default_env(CONFIG_ENV_VAR, DEFAULT_CONFIG_PATH))
  local fh = io.open(config_file, "r")
  local config
  if fh ~= nil then
    local content = fh:read("*a")
    fh:close()
    local success, conf = pcall(yaml.load, content)
    if not success then
      io.stderr:write("ERROR - failed to read yaml from configuration file\n")
      os.exit(1)
    end
    config = conf
  else
    io.stderr:write(
      string.format("WARN - '%s': configuration not found, injecting sample configuration\n", config_file)
    )
    config = DEFAULT_CONFIG
    write_default_config(config_file)
  end
  return parse_config(config)
end

---@class Config
---@field namespaces { [string]: Namespace }
---@field config table
return read_config()
