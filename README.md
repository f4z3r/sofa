# sofa

![GitHub License](https://img.shields.io/github/license/f4z3r/sofa?link=https%3A%2F%2Fgithub.com%2Ff4z3r%2Fsofa%2Fblob%2Fmain%2FLICENSE)
![GitHub Release](https://img.shields.io/github/v/release/f4z3r/sofa?logo=github&link=https%3A%2F%2Fgithub.com%2Ff4z3r%2Fsofa%2Freleases)
![LuaRocks](https://img.shields.io/luarocks/v/f4z3r/sofa?logo=lua&link=https%3A%2F%2Fluarocks.org%2Fmodules%2Ff4z3r%2Fsofa)

A command execution engine powered by `rofi`.

## Configuration

> [!WARNING]
> A configuration must be set, currently `sofa` cannot handle not having a configuration.

By default the configuration location is at `~/.config/sofa/config.yaml`. This can be set to a
different path using the `SOFA_CONFIG` environment variable.

### Namespaces

Namespace provide a way to organise your commands. They are provided as follows in the configuration
file:

```yaml
namespaces:
  <name1>:
    commands:
      ...
  <name2>:
    commands:
      ...
```

where `<name1>` and `<name2>` are the name of the namespaces.

Namespaces have the following fields:

- `commands`: a map of [commands](#commands) contained in the namespace.

### Commands

## Roadmap

- [ ] add documentation
- [ ] add configuration validation
- [ ] add logging for better reporting
- [ ] add configuration options
  - [ ] execution shell
  - [ ] log level
