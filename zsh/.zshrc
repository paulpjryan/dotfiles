export ZSH="$HOME/.oh-my-zsh"

# Keep custom config in a tracked, dotfiles-managed dir instead of $ZSH/custom,
# so `omz update` can never clobber it and work-only overlays can live alongside.
export ZSH_CUSTOM="$HOME/.zsh-custom"

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

ZSH_THEME="robbyrussell"
plugins=(git)

source "$HOME/.zsh/spaceship/spaceship.zsh"
source $ZSH/oh-my-zsh.sh
