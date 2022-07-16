#!/bin/sh
# Update required fonts
set -e

# Include the general functions
. ./functions/general

print_block "Updating fonts"

# Because OSX doesn't let you install fonts by symlink,
# lets rsync the folder, keeping things in sync
OSX_FONTS_DIR=~/Library/Fonts/Dotfiles
DOTFILES_FONTS_DIR="$DOTFILES/fonts"

rsync -avz --exclude-from $DOTFILES_FONTS_DIR/rsync-exclude $DOTFILES_FONTS_DIR/ $OSX_FONTS_DIR

# Get currently installed homebrew cask fonts
installedFonts=( $(brew list --cask | grep font) )

# Load list of applications to update from the fonts file
OLDIFS=$IFS; IFS=$'\n' fonts=($(egrep -v '(^#|^$)' $DOTFILES_FONTS_DIR/fonts)); IFS=$OLDIFS

# Add additional fonts array from .localrc to update non standard ones
fonts=("${fonts[@]}" "${CASKROOM_FONTS_EXTRA[@]}")

for app in "${fonts[@]}"; do
  # Check if it's not in the do not install array in .localrc
  if inArray "$app" "${CASKROOM_FONTS_IGNORE[@]}"; then
    print_line "Ignored" "${app}"
  else
    if inArray "$app" "${installedFonts[@]}"; then
      if [ "$skipMessages" == "true" ]; then
        print_line "Skipping" "${app}"
      fi
    else
      cask_install $app
    fi
  fi
done
