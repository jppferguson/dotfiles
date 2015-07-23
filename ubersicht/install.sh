#!/bin/sh
#
# Setup Übersicht widgets
#
###############################################################################

# Include the general functions
. $DOTFILES/functions/general

print_block "Installing Übersicht";

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
ln -s "${DOTFILES}/ubersicht/widgets" "${UBERSICHT_WIDGETS_DIR}"

print_block_end
