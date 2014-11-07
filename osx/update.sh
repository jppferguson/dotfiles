#!/bin/sh
# Check for OS X updates
set -e

echo "\nChecking for OSX updates...";

softwareupdate -l
# we're not really doing anything for now, so just list them out

# Run the set-defaults script
$DOTFILES/osx/set-defaults.sh
