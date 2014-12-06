#!/bin/sh
#
# Homebrew Cask
# Install native OSX apps with homebrew cask
#
###############################################################################

# Include the general functions
. ./functions/general

# Let the user know what's happening
print_block "Installing native applications"

# Make sure we have the latest and greatest
brew upgrade brew-cask 2> /dev/null

# Install apps to /Applications (Default is: /Users/$user/Applications)
. ./homebrew-cask/env.zsh
appsFolder=$HOMEBREW_CASK_OPTS

function cask_install() {
  brew cask install --appdir="$appsFolder" "${@}" 2> /dev/null
}

# Load list of applications to update from the apps file
IFS=$'\n' apps=($(egrep -v '(^#|^$)' $DOTFILES/homebrew-cask/apps))
# TODO: join additional apps array from .localrc to update non standard ones
for app in "${apps[@]}"; do
  # TODO: Check if its not in a do not install array in .localrc
  print_line "Installing" "${app}"
  cask_install $app
done

# Clean up cask
brew cask cleanup

# And we're done
print_block_end
