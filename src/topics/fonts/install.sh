#!/bin/sh
#
# Install required fonts
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Installing Fonts"

if ! command_exists brew; then
  print_error "Please install homebrew to install homebrew fonts!"
fi

# Install the fonts
sh $DOTFILES/src/topics/fonts/update.sh -s
