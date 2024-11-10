#!/bin/sh
#
# Install Übersicht
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Installing Übersicht"

# symlink widgets in
UBERSICHT_DIR="${HOME}/Library/Application Support/Übersicht"
UBERSICHT_WIDGETS_DIR="${UBERSICHT_DIR}/widgets"

# make sure file exists first
mkdir -p "${UBERSICHT_DIR}"

# backup old settings folder
if [ -f "${UBERSICHT_WIDGETS_DIR}" ]; then
  mv "${UBERSICHT_WIDGETS_DIR}" "${UBERSICHT_DIR}/widgets.backup"
fi

# symlink the Widgets folder
ln -s "${DOTFILES}/src/topics/ubersicht/widgets" "${UBERSICHT_WIDGETS_DIR}"

print_block_end
