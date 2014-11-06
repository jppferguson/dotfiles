#!/bin/sh
#
# git clone https://github.com/rupa/z
# z, oh how i love you
# Z - A cd command that learns - easily navigate directories from the command line
#
# Check for z

if [ ! -d "$VENDOR/z" ]; then
  echo "Installing z for you..."
  cd $VENDOR
  git clone https://github.com/rupa/z.git
  chmod +x $VENDOR/z/z.sh
  # also consider moving over your current .z file if possible. it's painful to rebuild :)
else
  . $VENDOR/z/z.sh
  if hash _z >/dev/null 2>&1; then echo "Z is already installed!"; else echo "Your Z installation failed!"; fi
fi


exit 0