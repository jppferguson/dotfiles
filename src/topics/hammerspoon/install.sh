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

if [ -d "/Applications/Hammerspoon.app" ] || brew list --cask hammerspoon > /dev/null 2>&1; then
  print_error "Hammerspoon is already installed"
else
  brew install hammerspoon
  echo "Hammerspoon installed."
fi

# SpoonInstall is a separate manual download, so check for it independently
if [ ! -d "$SPOON_INSTALL_DIR" ]; then
  echo "Download and install SpoonInstall and you should be good-to-go:"
  echo "> https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip"
fi
