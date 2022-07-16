#!/bin/sh
#
# Install PHP and friends
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing PHP and friends"

brew tap homebrew/php
brew install composer --ignore-dependencies
