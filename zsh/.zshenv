# Loaded for every shell (interactive and not), so secret env vars are available
# to scripts and tools too. The secrets file itself is local and gitignored.
[ -f "$HOME/.zsh-custom/secrets.zsh" ] && source "$HOME/.zsh-custom/secrets.zsh"
