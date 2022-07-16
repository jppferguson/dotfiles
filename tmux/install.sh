#!/bin/sh
#
# Install tmux
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing tmux"

# Install it with homebrew
brew install tmux
