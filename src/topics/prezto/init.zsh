
# Source Prezto.
# Use $HOME explicitly so prezto loads correctly when ZDOTDIR is overridden
# (e.g. by Wave terminal)
if [[ -s "$HOME/.zprezto/init.zsh" ]]; then
  local _saved_zdotdir="$ZDOTDIR"
  ZDOTDIR="$HOME"
  source "$HOME/.zprezto/init.zsh"
  ZDOTDIR="$_saved_zdotdir"
fi

# prompt theme is set via zpreztorc (zstyle ':prezto:module:prompt' theme)
