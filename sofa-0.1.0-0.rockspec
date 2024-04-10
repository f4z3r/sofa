local package_name = "sofa"
local package_version = "0.1.0"
local rockspec_revision = "0"
local github_account_name = "f4z3r"
local github_repo_name = package_name

rockspec_format = "3.0"
package = package_name
version = package_version .. "-" .. rockspec_revision

source = {
  url = "git://github.com/" .. github_account_name .. "/" .. github_repo_name .. ".git",
  tag = "v" .. package_version,
}

description = {
  summary = "A command execution engine powered by rofi.",
  detailed = [[
    A tool to organise and execute your commands, so convenient you can
    run it from your sofa.
  ]],
  homepage = "https://github.com/f4z3r/sofa",
  license = "MIT <http://opensource.org/licenses/MIT>",
}

dependencies = {
  "lua == 5.1",
  "argparse >= 0.7",
  "lyaml >= 6.2",
}

-- test_dependencies = {
--   "busted >= 2.0",
-- }
--
-- test = {
--   type = "busted",
-- }

build = {
  type = "builtin",
  modules = {
    ["sofa"] = "sofa/init.lua",
    ["sofa.rofi"] = "sofa/rofi.lua",
    ["sofa.config"] = "sofa/config.lua",
    ["sofa.namespace"] = "sofa/namespace.lua",
  },
  install = {
    bin = {
      ["sofa"] = "bin/sofa",
    },
  },
}
