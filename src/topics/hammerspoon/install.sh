#!/bin/sh
#
# Install hammerspoon
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Installing hammerspoon"

SPOON_INSTALL_DIR="${DOTFILES}/src/topics/hammerspoon/hammerspoon.symlink/Spoons/SpoonInstall.spoon"

if [ ! -d "$SPOON_INSTALL_DIR" ]; then
  brew install hammerspoon
  echo "Hammerspoon installed. Download and install SpoonInstall and you should be good-to-go:"
  echo "> https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip"
else
  print_error "Hammerspoon is already installed"
fi
