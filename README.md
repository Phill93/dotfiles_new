# Dotfiles

## Workstation requirements

- zsh with Homebrew, Antidote, and Spaceship
- neovim
  - git (for lazy.nvim and plugin installation)
  - yamllint (optional, enables YAML diagnostics)
- tmux

## Minimal server setup

The server profile manages Zsh, Tmux, aliases/functions, and iTerm2 shell
integration. It intentionally excludes Git configuration, Neovim, GnuPG,
SSH/assh, and all workstation-specific settings.

Apply the profile explicitly with Chezmoi:

```sh
chezmoi apply --source /path/to/dotfiles_new --override-data '{"server":true}'
```

To persist the selection, add the following to your Chezmoi configuration:

```toml
[data]
server = true
# Optional: set the Git identity managed by this repository.
email = "you@example.com"
```

Then run the bootstrap script:

```sh
./install_server.sh
```

On Debian, Ubuntu, and Arch, it installs `zsh`, `git`, `curl`, and `tmux` via
the system package manager, then clones Antidote and Spaceship into the current
user's home directory; Homebrew is not used on Linux. Git is installed only as
a bootstrap dependency and no Git configuration is managed. On macOS, it
installs Homebrew when needed and installs the same tools plus Antidote and
Spaceship with Homebrew.
