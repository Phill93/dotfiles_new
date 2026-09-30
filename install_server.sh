#!/usr/bin/env bash

set -Eeuo pipefail

readonly ANTIDOTE_REPOSITORY="https://github.com/mattmc3/antidote.git"
readonly ANTIDOTE_DIRECTORY="$HOME/.antidote"
readonly SPACESHIP_REPOSITORY="https://github.com/spaceship-prompt/spaceship-prompt.git"
readonly SPACESHIP_DIRECTORY="$HOME/.zsh/spaceship"
readonly ITERM2_INTEGRATION_URL="https://iterm2.com/shell_integration/zsh"
readonly ITERM2_INTEGRATION_FILE="$HOME/bin/iterm2_integration.zsh"

dry_run=false

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

install_system_packages() {
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

  [ -r "$plugins_file" ] || die "missing $plugins_file; apply the Chezmoi server profile first"

  if "$dry_run"; then
    info '+ zsh -dfc <build Antidote static file>'
    return
  fi

  static_temporary_file="$(mktemp "${static_file}.XXXXXX")"
  trap 'rm -f "$static_temporary_file"' RETURN
  zsh -dfc 'source "$1" && antidote bundle < "$2" > "$3"' \
    zsh "$ANTIDOTE_DIRECTORY/antidote.zsh" "$plugins_file" "$static_temporary_file"
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

  install_system_packages
  clone_or_update "$ANTIDOTE_REPOSITORY" "$ANTIDOTE_DIRECTORY"
  clone_or_update "$SPACESHIP_REPOSITORY" "$SPACESHIP_DIRECTORY"
  install_iterm2_integration
  build_antidote_static_file
  info 'Server tools are ready. Start zsh or run: exec zsh'
}

main "$@"
