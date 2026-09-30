# Dotfiles

## Workstation requirements

- zsh with Homebrew, Antidote, and Spaceship
- neovim
  - git (for lazy.nvim and plugin installation)
  - yamllint (optional, enables YAML diagnostics)
- tmux

## Minimal server setup

The server profile manages Zsh, Git, Tmux, aliases/functions, and iTerm2 shell
integration. It intentionally excludes Neovim, GnuPG, SSH/assh, and all
macOS-specific settings.

Apply the profile explicitly with Chezmoi:

```sh
chezmoi apply --source /path/to/dotfiles_new --override-data server=true
```

To persist the selection, add the following to your Chezmoi configuration:

```toml
[data]
server = true
```

Then, on Debian, Ubuntu, or Arch, run:

```sh
./install_server.sh
```

The script installs `zsh`, `git`, `curl`, and `tmux` via the system package
manager. Antidote and Spaceship are cloned from their upstream Git repositories
into the current user's home directory; Homebrew is not used on Linux.
