#!/bin/sh
#
# Install z
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing z"

Z_INSTALL_DIR="~/.zprezto-contrib/zsh-z"

if [ -d "$Z_INSTALL_DIR" ]; then
  git clone https://github.com/agkozak/zsh-z.git $Z_INSTALL_DIR
else
  print_error "z is already installed"
fi