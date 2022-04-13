#!/bin/bash

# Clone dotfiles repo (used if running install remotely)
REPO_LOCATION=~/dotfiles

# if [ ! -d "$DOTFILES" ]; then
#   env git clone https://github.com/paulpjryan/dotfiles.git $DOTFILES || {
#     echo "Error: git clone of dotfiles repo failed"
#     exit 1
#   }
# fi

# Install oh my zsh
echo "Installing oh my zsh"
if [ ! -n "$ZSH" ]; then
  hijack_env() {
    if [[ "$1" != "zsh" ]]; then
      env "$@"
    fi
  }

  alias env="hijack_env"
  curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -so - | sh
  unalias env
fi
echo "oh my zsh installed"

# Install Spaceship zsh theme
echo "Installing spaceship zsh theme"
ZSH_CUSTOM=~/.oh-my-zsh/custom
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme" > /dev/null
echo "spaceship zsh theme installed"

# Install zsh autosuggestions
echo "Installing zsh autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
echo "zsh autosuggestions installed"

# Install powerline fonts
# echo "Do you want to install Powerline fonts? [Y/N]"
# read choice
# if [[ $choice = 'Y' ]] || [[ $choice = 'y' ]]; then
#   TMP_POWERLINE_FONTS=tmp-install-fonts
#   env git clone --depth=1 https://github.com/powerline/fonts.git $TMP_POWERLINE_FONTS
#   cd $TMP_POWERLINE_FONTS
#   sh ./install.sh
#   cd ..
#   rm -rf $TMP_POWERLINE_FONTS
#   echo "Powerline fonts installed."
# else
#   echo "Powerline fonts skipped."
# fi

echo "Symlinking dotfiles"
for i in `find $REPO_LOCATION/dotfiles/* -maxdepth 1`; do
  original_file=`basename $i`

  if [[ "$original_file" != "dotfiles" ]]; then
    ln -snfv $i ~/.${original_file} > /dev/null
  fi
done

ln -snfv $REPO_LOCATION/dotfiles/custom.zsh $ZSH_CUSTOM/custom.zsh > /dev/null
echo "dotfiles symlinked"

if [ -e $HOME/.ssh/environment ]; then
    sed -i '/SHELL=.*/d' $HOME/.ssh/environment
fi

env zsh
