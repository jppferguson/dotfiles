#!/bin/sh
#
# Update homebrew
#
###############################################################################

# Include the general functions
. ./functions/general

# Let the user know what's happening
print_block "Updating Homebrew"

brew update

# And we're done
print_block_end
