# Configuration

---

**Table of Contents:**

<!--toc:start-->
- [Configuration](#configuration)
  - [Configuration Location](#configuration-location)
  - [Sample](#sample)
  - [Namespaces](#namespaces)
  - [Commands](#commands)
  - [Parameters](#parameters)
  - [Other Configuration](#other-configuration)
<!--toc:end-->

---

## Configuration Location

By default the configuration location is at `~/.config/sofa/config.yaml`. This can be set to a
different path using the `SOFA_CONFIG` environment variable.

## Sample

A basic sample configuration can be found under [`assets/config.yaml`](../assets/config.yaml).

My personal `sofa` configuration can be found
[in my Nix setup](https://github.com/f4z3r/nix/blob/master/home/files/sofa.yaml).

## Namespaces

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

**Required:**
- `commands`: a map of [commands](#commands) contained in the namespace.

## Commands

A command of name `<name>` has the following structure.

```yaml
<name>:
  command: nmcli d wifi connect '{{ network }}'
  description: Connect to a favourite wifi network.
  interactive: false
  tags:
  - local
  - clean
  parameters:
    network:
      prompt: Choose a network
      default: home
      exclusive: true
      choices:
      - home
      - work
      mapping:
        home: abc-123456
        work: office-wifi-other
```

**Required:**
- `command`: the command to execute. This can contain placeholders in double brackets such as
  `{{ network}}` which will get requested from the user. A placeholder can be used several times
  within the same command.

**Optional:**
- `description`: a description of what the command does. This will be printed when choosing
  commands.
- `interactive`: whether the command is interactive. This determines in what mode `sofa` will allow
  you to choose the command. Interactive commands are commands that should be run within a
  interactive shell (such as an interactive call to `ssh`). Default to `false`.
- `tags`: a list of tags which will not be visible, but can be used for filtering when searching for
  commands.
- `parameters`: a dictionary mapping a name to a [parameter](#parameters). The name of the parameter
  should match a placeholder in the command (`{{ network }}` in this case).

## Parameters

A parameter of name `<name>` has the following structure.

```yaml
<name>:
  prompt: Choose a network
  default: home
  exclusive: false
  choices:
  - home
  - work
  mapping:
    home: abc-123456
    work: office-wifi-other
    other: some-other-wifi
# or
<name>:
  prompt: Choose a network
  default: home
  exclusive: true
  choices: "nmcli --colors no -g ssid d wifi list"
# or
<name>:
  prompt: Session
  exclusive: true
  choices: "tmux list-sessions -F '#S: #{session_path} <span size='small'><i>(#{session_attached} attached, #{session_windows} windows)</i></span>'"
  mapping: "cut -d: -f1"
```

**Optional:**
- `prompt`: the prompt to show when picking that parameter in the picker. Defaults to the name of
  the parameter.
- `default`: the default value to use for the parameter if nothing is chosen. If `choices` is not
  provided, it is the value that will be picked if no input is given. If `choices` is provided, this
  should match an entry in `choices`, and will determine which element will get selected by default
  when the picker starts.
- `exclusive`: whether to allow entries not provided in `choices`. This only makes if `choices` is
  set. Defaults to `false`.
- `choices`: a list of available choices for that parameter. Alternatively a command can be passed
   as a string, in which case the choices are computed via that command.

   > [!NOTE]
   > If `choices` is a command, it can reference previously selected parameter values using the same
   > notations as placeholders in standard commands. For instance the `choices` command
   >
   >```sh
   > nmcli --colors no -g ssid d wifi list {{ interfaces_name }}
   > ```
   >
   > can be used to reference the value of the `interface_name` parameter previously selected.

- `mapping`: a mapping which allows to turn a chosen option into another value before applying it to
  the command. In this case, if `other` is manually provided (allowed  even though `other` is not
  in `choices` since `exclusive: false`), the string `some-other-wifi` will get injected into the
  command. Alternatively, a command can be given instead of a map. In that case the command will be
  executed with the chosen key provided to stdin.

## Other Configuration

This block allows you to configure general settings.

```yaml
config:
  log: ~/.local/state/sofa/sofa.log
  shell: bash
  picker: rofi
  pickers:
    fzf:
      default_options: "--no-multi --cycle --ansi"
```

**Optional:**
- `log`: the log file to use. Defaults to `~/.local/state/sofa/sofa.log`.
- `shell`: configure with what shell the command should be executed with when not running in
  interactive mode. Can be `bash`, `zsh`, `fish`. Defaults to `bash`.
- `picker`: which picker to use. Can be either `rofi` or `fzf`. Defaults to `rofi`.
- `pickers`: configuration for individual pickers.
- `pickers.fzf`: configuration for the `fzf` picker.
- `pickers.fzf.default_options`: the default options to pass to `fzf`. Defaults to `--no-multi
  --cycle --ansi`. Note that not passing options such as `--ansi` might break when using colors.

> [!NOTE]
> `sofa` respects [`NO_COLOR`](https://no-color.org/) and will not add additional colors to its
> output if the environment variable is set. `sofa` will however not modify existing `fzf`
> configuration, so `fzf` might still print colored output to the terminal.
