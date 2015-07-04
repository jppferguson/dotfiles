#!/bin/sh
#
# Homebrew Cask
# Install native OSX apps with homebrew cask
#
###############################################################################

# Allow using flags when running this script directly
forceInstall=''
skipMessages=''
while getopts 'fs' flag; do
  case "${flag}" in
    f) forceInstall='true' ;;
    s) skipMessages='true' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

# Include the general functions
. $DOTFILES/functions/general

# Include ~/.localrc for any custom stuff
. ~/.localrc

# Let the user know what's happening
print_block "Installing native applications"

# Make sure we have the latest and greatest
brew upgrade brew-cask 2> /dev/null

# Install apps to /Applications (Default is: /Users/$user/Applications)
appdir="/Applications"

function cask_install() {
  print_task "Installing" "${@}"
  sudo brew cask install --appdir="$appdir" "${@}"
}

function cask_reinstall() {
  print_task "Installing ${@} (with force)"
  sudo brew cask install --appdir="$appdir" --force "${@}"
}

# get currently installed apps
installedApps=( $(brew cask list) )

# Load list of applications to update from the apps file
OLDIFS=$IFS; IFS=$'\n' apps=($(egrep -v '(^#|^$)' $DOTFILES/homebrew-cask/apps)); IFS=$OLDIFS

# Add additional apps array from .localrc to update non standard ones
apps=("${apps[@]}" "${CASKROOM_APPS_EXTRA[@]}")

for app in "${apps[@]}"; do
  # Check if it's not in the do not install array in .localrc
  if inArray "$app" "${CASKROOM_APPS_IGNORE[@]}"; then
    print_line "Ignored" "${app}"
  else
    # Check if the force flag is set
    if [ "$forceInstall" == "true" ]; then
      cask_reinstall $app
    else
      if inArray "$app" "${installedApps[@]}"; then
        if [ "$skipMessages" == "true" ]; then
          print_line "Skipping" "${app}"
        fi
      else
        cask_install $app
      fi
    fi
  fi
done


# Clean up cask
brew cask cleanup

# And we're done
print_block_end
