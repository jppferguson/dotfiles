#!/bin/sh
#
# Z - A cd command that learns - easily navigate directories from the command line
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for z
if [ "`type -t z`" = 'function' ]
then
  echo "  Installing z for you."
  #ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)" > /tmp/homebrew-install.log
fi

# Install homebrew packages
#brew install grc coreutils spark

exit 0


#git clone https://github.com/rupa/z