#!/bin/sh
# Update required fonts
set -e

# Just run the install script again...
echo "\nUpdating fonts"
$DOTFILES/fonts/install.sh
