#!/usr/bin/env bats
#
# Covers the extension handling in src/topics/vs-code/{install,update}.sh
# against a temp HOME and DOTFILES with the code CLI stubbed on PATH, so no
# real extension is installed or removed.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export DOTFILES="$BATS_TEST_TMPDIR/dotfiles"
  mkdir -p "$HOME" "$BATS_TEST_TMPDIR/bin" "$DOTFILES/src"
  cp -R "$REPO/src/functions" "$DOTFILES/src/functions"
  cp -R "$REPO/src/topics" "$DOTFILES/src/topics"
  printf 'aaa.first\nbbb.second\n' > "$DOTFILES/src/topics/vs-code/extensions.txt"

  # Records every call; --list-extensions reports what INSTALLED lists
  cat > "$BATS_TEST_TMPDIR/bin/code" <<'STUB'
#!/bin/sh
echo "code $*" >> "$BATS_TEST_TMPDIR/code.log"
if [ "$1" = --list-extensions ]; then
  printf '%s\n' $INSTALLED
fi
STUB
  chmod +x "$BATS_TEST_TMPDIR/bin/code"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

@test "vs-code extensions.txt is committed and sorted" {
  [ -s "$REPO/src/topics/vs-code/extensions.txt" ]
  run sort -c "$REPO/src/topics/vs-code/extensions.txt"
  [ "$status" -eq 0 ]
}

@test "vs-code install.sh: force-installs every listed extension" {
  run "$DOTFILES/src/topics/vs-code/install.sh"
  [ "$status" -eq 0 ]
  grep -qx 'code --install-extension aaa.first --force' "$BATS_TEST_TMPDIR/code.log"
  grep -qx 'code --install-extension bbb.second --force' "$BATS_TEST_TMPDIR/code.log"
}

@test "vs-code install.sh: a second run succeeds and installs the same set again" {
  run "$DOTFILES/src/topics/vs-code/install.sh"
  [ "$status" -eq 0 ]
  run "$DOTFILES/src/topics/vs-code/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Could not install"* ]]
  [ "$(grep -c -- '--install-extension' "$BATS_TEST_TMPDIR/code.log")" -eq 4 ]
}

@test "vs-code install.sh: skips extensions without erroring when code is absent" {
  rm "$BATS_TEST_TMPDIR/bin/code"
  run env PATH="/usr/bin:/bin" "$DOTFILES/src/topics/vs-code/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"the code CLI is not on PATH"* ]]
}

@test "vs-code install.sh: warns and carries on when one extension fails" {
  cat > "$BATS_TEST_TMPDIR/bin/code" <<'STUB'
#!/bin/sh
echo "code $*" >> "$BATS_TEST_TMPDIR/code.log"
[ "$2" = aaa.first ] && exit 1
exit 0
STUB
  run "$DOTFILES/src/topics/vs-code/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Could not install aaa.first"* ]]
  grep -qx 'code --install-extension bbb.second --force' "$BATS_TEST_TMPDIR/code.log"
}

@test "vs-code update.sh: reports a match when the installed set equals extensions.txt" {
  INSTALLED="aaa.first bbb.second" run "$DOTFILES/src/topics/vs-code/update.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Extensions match"* ]]
}

@test "vs-code update.sh: prints a diff when the installed set has drifted" {
  INSTALLED="aaa.first ccc.third" run "$DOTFILES/src/topics/vs-code/update.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"-bbb.second"* ]]
  [[ "$output" == *"+ccc.third"* ]]
}

@test "vs-code update.sh: skips without erroring when code is absent" {
  rm "$BATS_TEST_TMPDIR/bin/code"
  run env PATH="/usr/bin:/bin" "$DOTFILES/src/topics/vs-code/update.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"the code CLI is not on PATH"* ]]
}

@test "vs-code update.sh: fails and reports when code --list-extensions fails" {
  cat > "$BATS_TEST_TMPDIR/bin/code" <<'STUB'
#!/bin/sh
exit 3
STUB
  run "$DOTFILES/src/topics/vs-code/update.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"code --list-extensions failed"* ]]
  [[ "$output" != *"-aaa.first"* ]]
}

@test "vs-code update.sh: drift exits 0 and never calls install or uninstall" {
  INSTALLED="aaa.first ccc.third" run "$DOTFILES/src/topics/vs-code/update.sh"
  [ "$status" -eq 0 ]
  run grep -E -- '--(un)?install-extension' "$BATS_TEST_TMPDIR/code.log"
  [ "$status" -ne 0 ]
}

@test "topgrade.toml wires vs-code update.sh into the dot update path" {
  grep -q 'src/topics/vs-code/update.sh' "$REPO/src/topics/topgrade/.config/topgrade.toml.symlink"
}

@test "topgrade command line runs update.sh with DOTFILES unset in the parent" {
  command_line=$(sed -n "s/^\"VS Code extensions\" = '\(.*\)'$/\1/p" "$REPO/src/topics/topgrade/.config/topgrade.toml.symlink")
  [ -n "$command_line" ]
  mkdir -p "$HOME/.dotfiles"
  cp -R "$DOTFILES/src" "$HOME/.dotfiles/src"
  INSTALLED="aaa.first bbb.second" run env -u DOTFILES bash -c "$command_line"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Extensions match"* ]]
}

@test "topgrade command line honours an inherited DOTFILES checkout" {
  command_line=$(sed -n "s/^\"VS Code extensions\" = '\(.*\)'$/\1/p" "$REPO/src/topics/topgrade/.config/topgrade.toml.symlink")
  alt_checkout="$BATS_TEST_TMPDIR/alt-checkout"
  mkdir -p "$alt_checkout/src/topics/vs-code"
  printf '#!/bin/bash\necho "ran from $DOTFILES"\n' > "$alt_checkout/src/topics/vs-code/update.sh"
  run env DOTFILES="$alt_checkout" bash -c "$command_line"
  [ "$status" -eq 0 ]
  [ "$output" = "ran from $alt_checkout" ]
}
