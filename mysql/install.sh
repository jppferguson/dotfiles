#!/bin/sh
#
# Set up a lamp environment on your mac
#
###############################################################################

brew install -v mysql

cp -v $(brew --prefix mysql)/support-files/my-default.cnf $(brew --prefix mysql)/my.cnf

cat >> $(brew --prefix mysql)/my.cnf <<'EOF'
# Echo & Co. changes
max_allowed_packet = 2G
innodb_file_per_table = 1
EOF

sed -i '' 's/^# \(innodb_buffer_pool_size\)/\1/' $(brew --prefix mysql)/my.cnf


[ ! -d ~/Library/LaunchAgents ] && mkdir -v ~/Library/LaunchAgents

[ -f $(brew --prefix mysql)/homebrew.mxcl.mysql.plist ] && ln -sfv $(brew --prefix mysql)/homebrew.mxcl.mysql.plist ~/Library/LaunchAgents/

[ -e ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist ] && launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist


# at least set a password for the root user
$(brew --prefix mysql)/bin/mysql_secure_installation
