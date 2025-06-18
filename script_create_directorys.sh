#!/bin/bash

if [ ! -d ~/bin ]; then
  mkdir -p ~/bin
fi

if [ ! -f ~/bin/iterm2_integration.zsh ]; then
  curl -L https://iterm2.com/shell_integration/zsh -o ~/bin/iterm2_integration.zsh
fi
