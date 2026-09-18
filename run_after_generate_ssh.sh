#!/bin/bash

if command -v assh > /dev/null; then
  assh config build > "${HOME}/.ssh/config"
fi
