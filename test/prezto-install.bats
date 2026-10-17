#!/usr/bin/env bats
#
# Covers src/topics/prezto/install.sh against a temp HOME with git stubbed on
# PATH, so nothing touches the real ~/.zprezto or the network.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup() {
  export DOTFILES="$REPO"
  export HOME="$BATS_TEST_TMPDIR/home"
  unset ZDOTDIR
  mkdir -p "$HOME" "$BATS_TEST_TMPDIR/bin"

  # A clone creates the target directory with a .git, as the real one would
  cat > "$BATS_TEST_TMPDIR/bin/git" <<'STUB'
#!/bin/sh
echo "git $*" >> "$BATS_TEST_TMPDIR/git.log"
if [ "$1" = clone ]; then
  mkdir -p "$(eval echo \${$#})/.git"
fi
STUB
  chmod +x "$BATS_TEST_TMPDIR/bin/git"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

@test "prezto install.sh: clones recursively when ~/.zprezto does not exist" {
  run bash "$REPO/src/topics/prezto/install.sh"
  [ "$status" -eq 0 ]
  grep -q "git clone --recursive https://github.com/sorin-ionescu/prezto.git $HOME/.zprezto" "$BATS_TEST_TMPDIR/git.log"
}

@test "prezto install.sh: succeeds on a second and third run, pulling instead of cloning" {
  run bash "$REPO/src/topics/prezto/install.sh"
  [ "$status" -eq 0 ]
  run bash "$REPO/src/topics/prezto/install.sh"
  [ "$status" -eq 0 ]
  run bash "$REPO/src/topics/prezto/install.sh"
  [ "$status" -eq 0 ]
  [ "$(grep -c 'git clone' "$BATS_TEST_TMPDIR/git.log")" -eq 1 ]
  [ "$(grep -c "git -C $HOME/.zprezto pull" "$BATS_TEST_TMPDIR/git.log")" -eq 2 ]
}

@test "prezto install.sh: updates submodules after the pull on a re-run" {
  run bash "$REPO/src/topics/prezto/install.sh"
  [ "$status" -eq 0 ]
  run bash "$REPO/src/topics/prezto/install.sh"
  [ "$status" -eq 0 ]
  pull_line="$(grep -n "git -C $HOME/.zprezto pull" "$BATS_TEST_TMPDIR/git.log" | cut -d: -f1)"
  submodule_line="$(grep -n "git -C $HOME/.zprezto submodule update --init --recursive" "$BATS_TEST_TMPDIR/git.log" | cut -d: -f1)"
  [ -n "$pull_line" ]
  [ "$submodule_line" -gt "$pull_line" ]
}

@test "prezto install.sh: leaves an existing non-git ~/.zprezto alone" {
  mkdir -p "$HOME/.zprezto"
  run bash "$REPO/src/topics/prezto/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"You already have Prezto"* ]]
  [ ! -f "$BATS_TEST_TMPDIR/git.log" ]
}
