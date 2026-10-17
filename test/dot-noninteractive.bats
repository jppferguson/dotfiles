#!/usr/bin/env bats
#
# Covers `dot` in non-interactive shells (ssh host 'dot ...'): no DOTFILES
# and no TERM in the environment.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

@test "dot: derives DOTFILES from its own location when unset" {
  # dot cd execs an interactive $SHELL, so give it EOF or it waits on the
  # caller's stdin forever
  run env -u DOTFILES -u TERM SHELL=/bin/sh "$REPO/src/bin/dot" cd </dev/null
  [[ "$output" != *"No such file or directory"* ]]
  run env -u DOTFILES -u TERM bash -c "$REPO/src/bin/dot help >/dev/null && echo ok"
  [ "$status" -eq 0 ]
}

@test "dot: derives DOTFILES through a symlink" {
  ln -s "$REPO/src/bin/dot" "$BATS_TEST_TMPDIR/dot"
  run env -u DOTFILES -u TERM "$BATS_TEST_TMPDIR/dot" claude status
  [[ "$output" != *"No such file or directory"* ]]
}

@test "dot: an explicitly set DOTFILES is respected" {
  fixture="$BATS_TEST_TMPDIR/dotfiles"
  mkdir -p "$fixture/src/topics/working"
  echo 'echo "fixture ran"' > "$fixture/src/topics/working/install.sh"
  run env -u TERM DOTFILES="$fixture" "$REPO/src/bin/dot" install working
  [ "$status" -eq 0 ]
  [[ "$output" == *"fixture ran"* ]]
}

@test "general: sourcing with no TERM prints no tput errors and leaves colours empty" {
  run env -u TERM bash -c ". '$REPO/src/functions/general'; echo \"[\$cRed\$cNo\$cCyan]\""
  [ "$status" -eq 0 ]
  [ "$output" = "[]" ]
}

@test "general: sourcing under set -e with TERM=dumb succeeds and leaves colours empty" {
  run env TERM=dumb bash -c "set -e; . '$REPO/src/functions/general'; echo \"[\$cRed\$cNo\$cCyan]\""
  [ "$status" -eq 0 ]
  [ "$output" = "[]" ]
}

@test "general: sourcing with a valid TERM still populates the colour variables" {
  run env TERM=xterm-256color bash -c ". '$REPO/src/functions/general'; [ -n \"\$cRed\" ] && [ -n \"\$cNo\" ] && echo populated"
  [ "$output" = "populated" ]
}

@test "dot symlink --prune dry run completes with TERM unset" {
  run env -u TERM "$REPO/src/bin/dot" symlink --prune
  [[ "$output" != *"tput:"* ]]
  [ "$status" -eq 0 ]
}
