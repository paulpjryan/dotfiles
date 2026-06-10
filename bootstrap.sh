#!/usr/bin/env bash
#
# Idempotent dotfiles installer. Safe to re-run on an already-configured machine.
#
#   git clone https://github.com/paulpjryan/dotfiles.git ~/dotfiles
#   ~/dotfiles/bootstrap.sh
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }

# 1. Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

log "Installing general packages (Brewfile)"
brew bundle --file="$DOTFILES/Brewfile"

if [ -f "$DOTFILES/Brewfile.work" ]; then
  log "Installing work packages (Brewfile.work)"
  brew bundle --file="$DOTFILES/Brewfile.work"
fi

# 2. oh-my-zsh + spaceship prompt ------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ ! -d "$HOME/.zsh/spaceship" ]; then
  log "Installing spaceship prompt"
  git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.zsh/spaceship"
fi

# 3. Symlink dotfiles via stow ---------------------------------------------
# --no-folding keeps ~/.zsh-custom a real directory so local overlays
# (secrets.zsh, company.zsh) can sit beside the symlinked tracked files.
mkdir -p "$HOME/.zsh-custom"

log "Symlinking dotfiles with stow"
for existing in "$HOME/.zshrc" "$HOME/.gitconfig"; do
  if [ -e "$existing" ] && [ ! -L "$existing" ]; then
    mv "$existing" "$existing.pre-dotfiles"
    log "Moved aside $existing -> $existing.pre-dotfiles"
  fi
done
stow --no-folding --dir="$DOTFILES" --target="$HOME" zsh git

# 4. Seed local overlays from examples (only if missing) -------------------
seed() {  # seed <example> <dest>
  if [ ! -e "$2" ]; then
    cp "$1" "$2"
    log "Seeded $2 (fill it in)"
  fi
}
seed "$DOTFILES/zsh/.zsh-custom/secrets.zsh.example" "$HOME/.zsh-custom/secrets.zsh"

# Git identity for this machine — prompted, never committed.
if [ ! -e "$HOME/.gitconfig.local" ]; then
  if [ -t 0 ]; then
    log "Git identity for this machine"
    read -rp "  git user.name: " git_name
    read -rp "  git user.email: " git_email
    printf '[user]\n\tname = %s\n\temail = %s\n' "$git_name" "$git_email" > "$HOME/.gitconfig.local"
    log "Wrote ~/.gitconfig.local"
  else
    cp "$DOTFILES/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
    log "No TTY; seeded ~/.gitconfig.local from example (edit it to set your name/email)"
  fi
fi

log "Done. Open a new shell, then fill in ~/.zsh-custom/secrets.zsh."
log "On a work machine: cp Brewfile.work.example Brewfile.work and company.zsh.example ~/.zsh-custom/company.zsh, then re-run."
