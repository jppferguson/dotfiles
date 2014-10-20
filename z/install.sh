#!/bin/sh
#
# git clone https://github.com/rupa/z
# z, oh how i love you
# Z - A cd command that learns - easily navigate directories from the command line
#

# Check for z
if [ "`type -t z`" = 'function' ]
then
  echo "  Installing z for you."

  cd $VENDOR
  git clone https://github.com/rupa/z.git
  chmod +x $VENDOR/z/z.sh
  # also consider moving over your current .z file if possible. it's painful to rebuild :)
fi

