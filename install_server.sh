#!/usr/bin/env bash

set -Eeuo pipefail

readonly ANTIDOTE_REPOSITORY="https://github.com/mattmc3/antidote.git"
readonly ANTIDOTE_DIRECTORY="$HOME/.antidote"
readonly SPACESHIP_REPOSITORY="https://github.com/spaceship-prompt/spaceship-prompt.git"
readonly SPACESHIP_DIRECTORY="$HOME/.zsh/spaceship"
readonly ITERM2_INTEGRATION_URL="https://iterm2.com/shell_integration/zsh"
readonly ITERM2_INTEGRATION_FILE="$HOME/bin/iterm2_integration.zsh"

dry_run=false
platform=""
brew_command=""

usage() {
  printf 'Usage: %s [--dry-run]\n' "${0##*/}"
}

info() {
  printf '%s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

run() {
  if "$dry_run"; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

find_homebrew() {
  local candidate

  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return
  fi

  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return
    fi
  done

  return 1
}

install_macos_packages() {
  if ! brew_command="$(find_homebrew)"; then
    if "$dry_run"; then
      # shellcheck disable=SC2016 # Display the literal installer command in dry-run mode.
      info '+ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    else
      /bin/bash -c "$(curl --fail --location --silent --show-error https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew_command="$(find_homebrew)" || die 'Homebrew installation completed but brew was not found'
  fi

  run "$brew_command" install zsh git curl tmux antidote spaceship
}

install_linux_packages() {
  local package_manager

  if command -v apt-get >/dev/null 2>&1; then
    package_manager=apt-get
  elif command -v pacman >/dev/null 2>&1; then
    package_manager=pacman
  else
    die 'supported package manager not found (expected apt-get or pacman)'
  fi

  if ! "$dry_run" && ! command -v sudo >/dev/null 2>&1; then
    die 'sudo is required to install system packages'
  fi

  case "$package_manager" in
    apt-get)
      run sudo apt-get update
      run sudo env DEBIAN_FRONTEND=noninteractive apt-get install --yes zsh git curl tmux
      ;;
    pacman)
      run sudo pacman --sync --needed --noconfirm zsh git curl tmux
      ;;
  esac
}

install_system_packages() {
  case "$platform" in
    darwin) install_macos_packages ;;
    linux) install_linux_packages ;;
    *) die "unsupported operating system: $platform" ;;
  esac
}

clone_or_update() {
  local repository=$1 directory=$2

  if [ -d "$directory/.git" ]; then
    run git -C "$directory" pull --ff-only
  elif [ -e "$directory" ]; then
    die "cannot install $repository: $directory exists but is not a Git repository"
  else
    run mkdir -p "$(dirname "$directory")"
    run git clone --depth=1 "$repository" "$directory"
  fi
}

install_iterm2_integration() {
  if [ -f "$ITERM2_INTEGRATION_FILE" ]; then
    return
  fi

  run mkdir -p "$(dirname "$ITERM2_INTEGRATION_FILE")"
  run curl --fail --location --silent --show-error "$ITERM2_INTEGRATION_URL" --output "$ITERM2_INTEGRATION_FILE"
}

build_antidote_static_file() {
  local plugins_file="$HOME/.zsh_plugins.txt"
  local static_file="$HOME/.zsh_plugins.zsh"
  local static_temporary_file
  local antidote_file

  [ -r "$plugins_file" ] || die "missing $plugins_file; apply the Chezmoi server profile first"

  if "$dry_run"; then
    info '+ zsh -dfc <build Antidote static file>'
    return
  fi

  if [ "$platform" = darwin ]; then
    antidote_file="$("$brew_command" --prefix antidote)/share/antidote/antidote.zsh"
  else
    antidote_file="$ANTIDOTE_DIRECTORY/antidote.zsh"
  fi
  [ -r "$antidote_file" ] || die "Antidote was not found at $antidote_file"

  static_temporary_file="$(mktemp "${static_file}.XXXXXX")"
  trap 'rm -f "$static_temporary_file"' RETURN
  zsh -dfc 'source "$1" && antidote bundle < "$2" > "$3"' \
    zsh "$antidote_file" "$plugins_file" "$static_temporary_file"
  mv "$static_temporary_file" "$static_file"
  trap - RETURN
}

main() {
  case "${1:-}" in
    '') ;;
    --dry-run) dry_run=true ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac

  [ "$(id -u)" -ne 0 ] || die 'run this script as the target user, not root'

  case "$(uname -s)" in
    Darwin) platform=darwin ;;
    Linux) platform=linux ;;
    *) die "unsupported operating system: $(uname -s)" ;;
  esac

  install_system_packages
  if [ "$platform" = linux ]; then
    clone_or_update "$ANTIDOTE_REPOSITORY" "$ANTIDOTE_DIRECTORY"
    clone_or_update "$SPACESHIP_REPOSITORY" "$SPACESHIP_DIRECTORY"
  fi
  install_iterm2_integration
  build_antidote_static_file
  info 'Server tools are ready. Start zsh or run: exec zsh'
}

main "$@"
