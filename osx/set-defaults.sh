#!/usr/bin/env bash
#
# Sets stuff the way I like it in OS X.
#  http://jppf.me/osx
#
#    The original idea (and a 99% of the settings) were grabbed from:
#    http://mths.be/osx
#
#
# Run `dot` and this will get automatically run.
#
###############################################################################

# Include the general functions
. ./functions/general

# check this is actually an OSX machine
if [ $(uname -s) = 'Darwin' ]
then
  print_block "Setting OS X defaults";
else
  print_line "Not OSX... skipping OSX defaults."
  exit 0
fi

# Ask for the administrator password upfront
sudo -v

# Set the default shell to zsh
sudo chsh -s /bin/zsh `whoami`

# # Keep-alive: update existing `sudo` time stamp until we're done
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# find all the .osx default files and then run them iteratively
default_files=( $(find . -name "*.osx" ) )

# create an array of the apps we should now kill
# apps=(SystemUIServer cfprefsd)
apps=()
for file in "${default_files[@]}"
do
  # run each script
  sh -c "${file}"

  # create an array of the apps we should now kill
  if [[ $file == *Applications/* ]]
  then
    app=${file//.osx/}          # remove the .osx extension
    app=${app//_/ }             # remove app- prefix
    app=${app##*/}              # remove the path
    apps=("${apps[@]}" "$app")  # add to the apps array
  fi
done

# Kill affected applications
for app in "${apps[@]}"
do
    if [ "${app}" != "Terminal" ]
    then
      print_line "Killing" "${app}.app"
      killall "${app}" > /dev/null 2>&1
    fi
done

print_warning "Some of these changes require a logout/restart to take effect."

print_block_end
