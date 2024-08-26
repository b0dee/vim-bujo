#!/usr/bin/env bash

# Use privileged mode, to e.g. ignore $CDPATH.
set -p

# CD to test folder
cd "$( dirname "${BASH_SOURCE[0]}" )" || exit

# Run tests
vim -Nu vimrc -c '+Vader! bujo.vader'
