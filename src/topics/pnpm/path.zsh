export PNPM_HOME="$HOME/Library/pnpm"
# pnpm 10 links globals into $PNPM_HOME; pnpm 11 moves them to $PNPM_HOME/bin
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
