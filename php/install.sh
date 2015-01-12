#!/bin/sh
#
# PHP Stuff
# Installs php related things, which is just composer at the moment...
#
###############################################################################

# Include the general functions
. ./functions/general


print_block "Installing Composer"


brew tap homebrew/php
brew install composer --ignore-dependencies
