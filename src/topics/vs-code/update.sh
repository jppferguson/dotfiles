#!/usr/bin/env bash
#
# Show drift between the installed VS Code extensions and extensions.txt
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Checking VS Code extensions"

if ! command -v code >/dev/null 2>&1; then
  print_line "Skipping extensions:" "the code CLI is not on PATH"
  print_block_end
  exit 0
fi

INSTALLED_FILE="$(mktemp)"
trap 'rm -f "$INSTALLED_FILE"' EXIT
code --list-extensions | sort > "$INSTALLED_FILE"

# diff exits 1 when the lists differ, which is the output we want, not a failure
if diff -u "$DOTFILES/src/topics/vs-code/extensions.txt" "$INSTALLED_FILE"; then
  print_line "Extensions match:" "extensions.txt"
else
  print_line "Extensions differ:" "- only in extensions.txt, + only installed"
fi

# And we're done
print_block_end
