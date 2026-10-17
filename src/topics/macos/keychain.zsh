# Unlock the login Keychain once per SSH session so Keychain-backed credentials work remotely
if [[ -n $SSH_CONNECTION ]] && ! security show-keychain-info login.keychain-db >/dev/null 2>&1; then
  security unlock-keychain login.keychain-db
fi
