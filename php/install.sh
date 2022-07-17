#!/bin/sh
#
# PHP Stuff
# Installs php related things, which is just composer at the moment...
#
###############################################################################

# Include the general functions
. ./functions/general

print_block "Installing Composer"

brew install php@7.1

brew install composer --ignore-dependencies

print_block "Installing Valet+"

# install Valet+
composer global require weprovide/valet-plus

valet fix && valet install --with-mariadb