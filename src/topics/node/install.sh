#!/bin/sh
#
# Install Node.js, NPM, NVM and Yarn
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Installing Node.js and friends"

# Uninstall node if installed
brew uninstall --ignore-dependencies node
brew uninstall --force node

# Install nvm
brew install nvm
ln -s /opt/homebrew/opt/nvm ~/.nvm

# Reload terminal
source ~/.zshrc

# Install latest LTS Version
nvm install --lts

# Install yarn
brew install yarn

# Run updates
sh $DOTFILES/src/topics/node/update.sh -s
