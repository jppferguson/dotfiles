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
