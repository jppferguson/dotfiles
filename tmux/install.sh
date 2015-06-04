#!/bin/sh
#
# tmux
#   a terminal multiplexer
#
###############################################################################

# Include the general functions
. ./functions/general


print_block "Installing tmux"

# Install it with homebrew
brew install tmux
