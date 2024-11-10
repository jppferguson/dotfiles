#!/bin/sh
#
# Install PHP and friends
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Installing PHP and friends"

brew install php@7.1

brew install composer --ignore-dependencies

print_block "Installing Valet+"

# install Valet+
composer global require weprovide/valet-plus

valet fix && valet install --with-mariadb
