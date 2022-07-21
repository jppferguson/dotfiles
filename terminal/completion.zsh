# Load iterm shell integration (if installed)
ITERM2_SHELL_INTEGRATION_PATH="${HOME}/.iterm2_shell_integration.zsh"
if [[ -s $ITERM2_SHELL_INTEGRATION_PATH ]]; then
  source $ITERM2_SHELL_INTEGRATION_PATH
fi