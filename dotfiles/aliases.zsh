# General
alias o="open"
alias aliases="cat ~/.dotfiles/aliases.zsh"
alias fix-touchbar='pkill "Touch Bar agent";
killall "ControlStrip";'

# Secure your moviments and commands
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"

# Git
alias gs='git status'
alias new-branch='git checkout -b'
alias uncommit="git reset --soft HEAD^"

# Python
alias mypy='mypy-daemon'
