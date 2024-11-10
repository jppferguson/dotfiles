#!/bin/sh
#
# Install apache
#
###############################################################################
set -e

# Include the general functions
. $DOTFILES/src/functions/general

print_block "Installing apache"

# install dnsmasq and forward all requests to *.dev to localhost
brew install dnsmasq

cd $(brew --prefix)

mkdir -p etc

echo 'address=/.dev/127.0.0.1' > etc/dnsmasq.conf

sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons

sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

sudo mkdir -p /etc/resolver

sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dev'


# copy in default vhosts
# TODO, check they dont already exist
httpdvhosts="/private/etc/apache2/extra/httpd-vhosts.conf"
sudo cp ${httpdvhosts} ${httpdvhosts}.bak
sudo sh -c "cat ${httpdvhosts}.bak ${DOTFILES}/src/topics/apache/vhosts > ${httpdvhosts}"

# fixup httpd.conf
httpdconf="/private/etc/apache2/httpd.conf"
uncomment 'LoadModule vhost_alias_module libexec/apache2/mod_vhost_alias.so' $httpdconf
# enable php
uncomment 'LoadModule php7_module libexec/apache2/libphp7.so' $httpdconf
# enable mod_rewrite
uncomment 'LoadModule rewrite_module libexec/apache2/mod_rewrite.so' $httpdconf
uncomment 'Include /private/etc/apache2/extra/httpd-vhosts.conf' $httpdconf


# make required directories
sudo mkdir -p /var/www/home/public
sudo mkdir -p /var/www/sites/default/public
sudo chown -R `whoami` /var/www

# clone local homepage project
# TODO fork this repo and also ask if you want to include it
# git clone 'git@github.com:cmall/LocalHomePage.git' /var/www/home/public/

# restart apache
sudo apachectl restart
