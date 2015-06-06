#!/bin/sh
#
# Setup a machine for Sublime Text 3
#
###############################################################################

# Include the general functions
. ./functions/general

print_block "Installing Sublime Text Preferences";

# symlink settings in
SUBLIME_DIR="${HOME}/Library/Application Support/Sublime Text 3"
SUBLIME_PACKAGES_DIR="${SUBLIME_DIR}/Packages"

# make sure file exists first
mkdir -p "${SUBLIME_PACKAGES_DIR}"

# backup old settings folder
if [ -f "${SUBLIME_PACKAGES_DIR}/User" ]; then
	mv "${SUBLIME_PACKAGES_DIR}/User" "${SUBLIME_PACKAGES_DIR}/User.backup"
fi

# symlink the User folder
ln -s "${DOTFILES}/sublime/User" "${SUBLIME_PACKAGES_DIR}"

# Install package control
mkdir -p "${SUBLIME_DIR}/Installed Packages/"
ln -s "${DOTFILES}/sublime/Packages/Package Control.sublime-package" "${SUBLIME_DIR}/Installed Packages/Package Control.sublime-package"

print_block_end
