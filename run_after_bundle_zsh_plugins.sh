#!/bin/sh

set -eu

plugins_file="$HOME/.zsh_plugins.txt"
static_file="$HOME/.zsh_plugins.zsh"

[ -r "$plugins_file" ] || exit 0
command -v brew >/dev/null 2>&1 || exit 0

antidote_file="$(brew --prefix antidote 2>/dev/null)/share/antidote/antidote.zsh"
[ -r "$antidote_file" ] || exit 0

static_tmp="$(mktemp "${static_file}.XXXXXX")"
trap 'rm -f "$static_tmp"' EXIT

zsh -dfc 'source "$1" && antidote bundle < "$2" > "$3"' \
  zsh "$antidote_file" "$plugins_file" "$static_tmp"
mv "$static_tmp" "$static_file"
