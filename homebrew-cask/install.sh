#!/bin/sh
#
# Homebrew Cask
# This installs native applications using homebrew cask.
#
###############################################################################

# Include the general functions
. ./functions/general

# Check for Homebrew
if ! command_exists brew; then

  # No Homebrew, no Caskroom :(
  print_error "Nooooooo! Homebrew isn't installed! Can't install Caskroom."

else

  # Let the user know what's happening
  print_block "Installing Homebrew Cask"

  # Install homebrew cask
  brew install caskroom/cask/brew-cask

  # Install the versions cask so we can install beta versions of apps
  brew tap caskroom/versions

  # Hook up alfred
  brew cask alfred link

  # Install the apps
  sh ./homebrew-cask/update.sh

fi