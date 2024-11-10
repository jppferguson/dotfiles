#!/bin/sh
#
# Update node
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Updating node"

DOTFILES_NODE_DIR="$DOTFILES/src/topics/node"

# Update npm and global packages
npm install npm -g
npm update -g

# Update yarn
brew upgrade yarn

# Load list of global node_modules to update from the npm-global file
OLDIFS=$IFS; IFS=$'\n' node_modules=($(egrep -v '(^#|^$)' $DOTFILES_NODE_DIR/npm-global)); IFS=$OLDIFS

for module in "${node_modules[@]}"; do
  # Check if it's not in the do not install array in .localrc
  if inArray "$module" "${GLOBAL_NODE_MODULES_IGNORE[@]}"; then
    print_line "Ignored" "${module}"
  else
    print_line "Installing" ${module}
    npm install --global ${module}
  fi
done
