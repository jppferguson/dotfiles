#!/bin/sh
#
# Install Node.js, NPM, NVM and Yarn
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing Node.js and friends"

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
