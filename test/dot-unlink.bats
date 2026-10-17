#!/usr/bin/env bats
#
# Covers unlink_dotfiles (dot unlink) against a fixture HOME and DOTFILES.
# Never touches the real $HOME.

GENERAL="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/src/functions/general"

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export DOTFILES="$BATS_TEST_TMPDIR/dotfiles"
  DOTFILES_TOPIC_ROOT="$DOTFILES/src/topics"
  mkdir -p "$HOME" "$DOTFILES_TOPIC_ROOT/shell" "$DOTFILES_TOPIC_ROOT/ghostty/.config/ghostty"
  echo repo > "$DOTFILES_TOPIC_ROOT/shell/zshrc.symlink"
  echo repo > "$DOTFILES_TOPIC_ROOT/ghostty/.config/ghostty/config.symlink"
  . "$GENERAL"
}

link_all() {
  mkdir -p "$HOME/.config/ghostty"
  ln -s "$DOTFILES_TOPIC_ROOT/shell/zshrc.symlink" "$HOME/.zshrc"
  ln -s "$DOTFILES_TOPIC_ROOT/ghostty/.config/ghostty/config.symlink" "$HOME/.config/ghostty/config"
}

@test "unlink_dotfiles: removes every mapped link pointing into DOTFILES" {
  link_all

  unlink_dotfiles

  [ ! -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]
  [ ! -L "$HOME/.config/ghostty/config" ]
  [ -f "$DOTFILES_TOPIC_ROOT/shell/zshrc.symlink" ]
}

@test "unlink_dotfiles: leaves a real file and a link elsewhere untouched" {
  echo mine > "$HOME/.zshrc"
  echo other > "$BATS_TEST_TMPDIR/elsewhere"
  mkdir -p "$HOME/.config/ghostty"
  ln -s "$BATS_TEST_TMPDIR/elsewhere" "$HOME/.config/ghostty/config"

  unlink_dotfiles

  [ "$(cat "$HOME/.zshrc")" = mine ]
  [ "$(readlink "$HOME/.config/ghostty/config")" = "$BATS_TEST_TMPDIR/elsewhere" ]
}

@test "unlink_dotfiles: without restore does not copy backups back" {
  link_all
  mkdir -p "$HOME/.dotfiles_backup/100"
  echo old > "$HOME/.dotfiles_backup/100/.zshrc"

  unlink_dotfiles

  [ ! -e "$HOME/.zshrc" ]
}

@test "unlink_dotfiles true: restores the newest timestamped backup" {
  link_all
  mkdir -p "$HOME/.dotfiles_backup/100" "$HOME/.dotfiles_backup/9" "$HOME/.dotfiles_backup/200"
  echo older > "$HOME/.dotfiles_backup/100/.zshrc"
  echo oldest > "$HOME/.dotfiles_backup/9/.zshrc"
  echo newest > "$HOME/.dotfiles_backup/200/.zshrc"

  unlink_dotfiles true

  [ ! -L "$HOME/.zshrc" ]
  [ "$(cat "$HOME/.zshrc")" = newest ]
  [ "$(cat "$DOTFILES_TOPIC_ROOT/shell/zshrc.symlink")" = repo ]
}

@test "unlink_dotfiles true: skips timestamps lacking the file and uses an older one" {
  link_all
  mkdir -p "$HOME/.dotfiles_backup/100" "$HOME/.dotfiles_backup/200"
  echo older > "$HOME/.dotfiles_backup/100/.zshrc"
  echo unrelated > "$HOME/.dotfiles_backup/200/.gitconfig"

  unlink_dotfiles true

  [ "$(cat "$HOME/.zshrc")" = older ]
}

@test "unlink_dotfiles true: removes the link and carries on when no backup exists" {
  link_all
  mkdir -p "$HOME/.dotfiles_backup/100"
  echo cfg > "$HOME/.dotfiles_backup/100/config"

  run unlink_dotfiles true

  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]
  [ "$(cat "$HOME/.config/ghostty/config")" = cfg ]
}

@test "unlink_dotfiles true: works when ~/.dotfiles_backup does not exist" {
  link_all

  run unlink_dotfiles true

  [ "$status" -eq 0 ]
  [ ! -L "$HOME/.zshrc" ]
}
