# sofa

![GitHub License](https://img.shields.io/github/license/f4z3r/sofa?link=https%3A%2F%2Fgithub.com%2Ff4z3r%2Fsofa%2Fblob%2Fmain%2FLICENSE)
![GitHub Release](https://img.shields.io/github/v/release/f4z3r/sofa?logo=github&link=https%3A%2F%2Fgithub.com%2Ff4z3r%2Fsofa%2Freleases)
![LuaRocks](https://img.shields.io/luarocks/v/f4z3r/sofa?logo=lua&link=https%3A%2F%2Fluarocks.org%2Fmodules%2Ff4z3r%2Fsofa)
![LuaJIT](https://img.shields.io/badge/LuaJIT-_?logo=lua&labelColor=blue&color=blue)

A command execution engine powered by [`rofi`](https://github.com/davatorium/rofi).

---

**Table of Contents:**

<!--toc:start-->
- [sofa](#sofa)
  - [Examples](#examples)
    - [For Snippets Management](#for-snippets-management)
    - [For Dynamic Bookmarks](#for-dynamic-bookmarks)
  - [Installation](#installation)
  - [Integration](#integration)
    - [Bash](#bash)
    - [Zsh](#zsh)
    - [Fish](#fish)
  - [Configuration](#configuration)
  - [Roadmap](#roadmap)
<!--toc:end-->

---

## Examples

### For Snippets Management

You can use `sofa` for standard snippets management. Use the [integration](#integration) described
below, and have configuration such as:

<details>
<summary>Configuration</summary>

```yaml
namespaces:
  utils:
    commands:
      echo:
        command: echo "Hello {{ world }}. Welcome to my little place of the {{ world }}"
        description: Print a nice little test string
        interactive: true
        tags:
        - shell
```
</details>

![Shell](./assets/shell.gif)

### For Dynamic Bookmarks

Or launch `sofa` without interactive mode from a shortcut manager such as `sxhkd`:

<details>
<summary>Configuration</summary>

```yaml
namespaces:
  bookmarks:
    commands:
      github:
        command: xdg-open "https://github.com/{{ user }}/{{ project }}"
        description: Open a GitHub project in the browser
        tags:
        - github
        - coding
        parameters:
          user:
            default: f4z3r
            prompt: Choose user
          project:
            prompt: Choose project
```

</details>

![Bookmarks Launcher](./assets/bookmarks.gif)

---

My personal `sofa` configuration can be found
[in my Nix setup](https://github.com/f4z3r/nix/blob/master/home/files/sofa.yaml).

## Installation

> [!NOTE]
> Currently sofa is only tested with LuaJIT.

Of course, this is dependent on `rofi` being installed on your system.

Install via `luarocks`:

```bash
luarocks install sofa
```

## Integration

This section shows how to integrate `sofa` with your favourite shell. The following examples
showcase how to bind `sofa` to <kbd>Contrl</kbd> + <kbd>o</kbd>. Update the snippets to bind to your
preferred keys.

### Bash

Add the following lines to your `bash` configuration:

```sh
__interactive_sofa () {
    tput rmkx
    output="$(sofa -i)"
    tput smkx

    READLINE_LINE=${output}
    READLINE_POINT=${#READLINE_LINE}
}

bind -x '"\C-o": __interactive_sofa'
```

### Zsh

Add the following lines to your `zsh` configuration:

```sh
autoload -U add-zsh-hook

function _interactive_sofa() {
  emulate -L zsh
  zle -I

  echoti rmkx
  output=$(sofa -i)
  echoti smkx

  if [[ -n $output ]]; then
    LBUFFER=$output
  fi

  zle reset-prompt
}

zle -N _interactive_sofa_widget _interactive_sofa
bindkey '^o' _interactive_sofa_widget
```

### Fish

Add the following lines to your `fish` configuration:

```fish
# Hoard bindings
function __interactive_sofa
    set output (sofa -i)
    commandline -j $output
end

bind \co __interactive_sofa
```

## Configuration

See [`docs/configuration.md`](./docs/configuration.md).

## Roadmap

This shows some items I want to support. The list is not in order of priority.

- [ ] add configuration validation
- [ ] add logging for better reporting
- [ ] better documentation and screenshots on the capabilities
- [ ] support dependent choices (i.e. when X chosen for parameter 1, then provides choice list Y
      for parameter 2)
- [ ] add configuration options
  - [x] execution shell
  - [ ] log level
- [ ] add support for more Lua versions
- [ ] support executing commands in the background
