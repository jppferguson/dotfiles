#!/bin/sh
#
# Node.js & NPM
# Installs Node.js & NPM
#
###############################################################################

# Include the general functions
. ./functions/general

print_block "Installing Node.js"

# Install with homebrew
brew install node

# Install nvm
git clone https://github.com/creationix/nvm.git ~/.nvm
cd ~/.nvm
git checkout v0.33.5

# Install yarn
brew install yarn

# Run updates
sh $DOTFILES/node/update.sh -s
