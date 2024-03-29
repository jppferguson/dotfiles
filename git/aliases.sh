# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
# hub_path=$(which hub)
# if (( $+commands[hub] )); then
#   alias git=$hub_path
# fi

# The rest of my fun git aliases
alias gl='git pull --prune'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gloga="git log --oneline --decorate --all --graph --pretty=format:'%C(magenta bold) %h %C(white bold )%an %Creset: %s -%Creset%C(yellow)%d%Creset %Cgreen(%cr)%Creset'"
alias gp='git push origin HEAD'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gcb='git copy-branch-name'
alias gb='git branch'
alias gcln='git clone'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias ggui='gitgui'

# open with source tree
alias sourcetree='open -a SourceTree'
