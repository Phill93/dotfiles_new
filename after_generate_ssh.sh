#!/bin/bash

if ! type "assh" > /dev/null; then
  assh config build > "${HOME}/.ssh/config"
fi
