#!/bin/bash

if [ ! -d ~/bin ]; then
  mkdir -p ~/bin
fi

if [ ! -f ~/bin/iterm2_integration.zsh ]; then
  curl -L https://iterm2.com/shell_integration/zsh -o ~/bin/iterm2_integration.zsh
fi

if [ ! -d ~/tmp ]; then
  mkdir -p ~/tmp
fi

if [ ! -d ~/tmp/.ssh/cm/ ]; then
  mkdir -p ~/tmp/.ssh/cm/
fi
