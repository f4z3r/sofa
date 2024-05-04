{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (system: let
      pkgs = import nixpkgs {inherit system;};
      luaPackages = {
        lua54 = pkgs.lua54Packages;
        lua53 = pkgs.lua53Packages;
        lua52 = pkgs.lua52Packages;
        lua51 = pkgs.lua51Packages;
        luajit = pkgs.luajitPackages;
        default = pkgs.luajitPackages;
      };
      custom-lua-packages = luaPkgs:
        with luaPkgs; let
          luatext = buildLuarocksPackage {
            pname = "luatext";
            version = "1.2.0-0";
            knownRockspec =
              (pkgs.fetchurl {
                url = "mirror://luarocks/luatext-1.2.0-0.rockspec";
                sha256 = "1lmjhsnbpz4wkaypqaqas0rlahbhpsr0g9wgls6lsswh3dh5xx28";
              })
              .outPath;
            src = pkgs.fetchgit (removeAttrs (builtins.fromJSON ''              {
                "url": "https://github.com/f4z3r/luatext.git",
                "rev": "c8ada5144c7c23d44d37a10fa484fe91b34c11d0",
                "date": "2024-03-26T18:27:25+01:00",
                "path": "/nix/store/crga0pkvm25gwwns8n6jb9cakfkmjd90-luatext",
                "sha256": "0h6l7ws6baq5dxfs1ala8smm7pykh9vd13bxkh2a343hn834dx42",
                "hash": "sha256-gvRGBrJwkKEEnH2N0HaC099Tq0aKqqBdbwWrZTQ/1EA=",
                "fetchLFS": false,
                "fetchSubmodules": true,
                "deepClone": false,
                "leaveDotGit": false
              }
            '') ["date" "path" "sha256"]);

            disabled = luaOlder "5.1";
            propagatedBuildInputs = [lua];

            meta = {
              homepage = "https://github.com/f4z3r/luatext/tree/main";
              description = "A small library to print colored text";
              license.fullName = "MIT";
            };
          };
        in [luatext];
      makeLuaShell = shellName: luaPackage:
        pkgs.mkShell {
          packages = with luaPackage;
            [busted argparse lyaml compat53]
            ++ (custom-lua-packages luaPackage);
          shellHook = ''
            export LUA_PATH="./?.lua;./?/init.lua;$LUA_PATH"
          '';
        };
    in {
      devShells = builtins.mapAttrs makeLuaShell luaPackages;
    });
}
