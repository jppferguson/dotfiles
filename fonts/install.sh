#!/bin/sh
#
# Install required fonts
#
set -e

# Include the general functions
. ./functions/general

if ! command_exists brew; then

  # No Homebrew :(
  print_error "Please install homebrew and homebrew cask to install homebrew fonts!"

else

  # Install homebrew cask fonts
  brew tap caskroom/fonts

fi

# Install the fonts
sh $DOTFILES/fonts/update.sh -s
