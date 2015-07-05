
# Path to your oh-my-zsh configuration.
export ZSH=$VENDOR/oh-my-zsh

# move the custom folder outside of the oh-my-zsh repo
export ZSH_CUSTOM=$VENDOR/oh-my-zsh-custom

# Set name of the theme to load.
ZSH_THEME="agnoster"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(bower brew brew-cask colorize composer git-flow git node npm osx ruby sublime)

# disable oh-my-zsh updates entirely, only check when running `dot`
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true
