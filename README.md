# sofa

![GitHub License](https://img.shields.io/github/license/f4z3r/sofa?link=https%3A%2F%2Fgithub.com%2Ff4z3r%2Fsofa%2Fblob%2Fmain%2FLICENSE)
![GitHub Release](https://img.shields.io/github/v/release/f4z3r/sofa?logo=github&link=https%3A%2F%2Fgithub.com%2Ff4z3r%2Fsofa%2Freleases)
![LuaRocks](https://img.shields.io/luarocks/v/f4z3r/sofa?logo=lua&link=https%3A%2F%2Fluarocks.org%2Fmodules%2Ff4z3r%2Fsofa)
![LuaJIT](https://img.shields.io/badge/LuaJIT-_?logo=lua&labelColor=blue&color=blue)

A command execution engine powered by `rofi`.

---

**Table of Contents:**

<!--toc:start-->
- [sofa](#sofa)
  - [Example](#example)
  - [Installation](#installation)
  - [Integration](#integration)
    - [Bash](#bash)
    - [Zsh](#zsh)
    - [Fish](#fish)
  - [Configuration](#configuration)
  - [Roadmap](#roadmap)
<!--toc:end-->

---

## Example

## Installation

> [!NOTE]
> Currently sofa is only tested with LuaJIT.

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
  output=$(sofa --list)
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

- [ ] add configuration validation
- [ ] add logging for better reporting
- [ ] add configuration options
  - [ ] execution shell
  - [ ] log level
- [ ] add support for more Lua versions
