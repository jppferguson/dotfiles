#!/usr/bin/env bash
#
# Sets stuff the way I like it in OS X.
#  http://jppf.me/osx
#
#    The original idea (and a 99% of the settings) were grabbed from:
#    https://mths.be/macos
#
#
# Run `dot` and this will get automatically run.
#
###############################################################################

# Include the general functions
. $DOTFILES/src/functions/general

# check this is actually an macOS machine
if [ $(uname -s) = 'Darwin' ]
then
  print_block "Setting macOS defaults";
else
  print_line "Not macOS... skipping macOS defaults."
  exit 0
fi

if ! command_exists macos-defaults; then
  print_error "ERROR: Please install macos-defaults!"
  exit 0
fi

print_warning "If you get 'Could not write domain...' errors below, you may need to add your terminal app (e.g. Terminal.app, iTerm2) to System Preferences -> Privacy -> Full Disk Access"

macos-defaults apply $DOTFILES/src/topics/macos/defaults/

print_line "Some settings may require a logout/restart to take effect."

print_block_end
