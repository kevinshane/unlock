#!/bin/bash

# install zsh and ohmyzsh
apt install zsh -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# adding short command
echo "alias ls='lsd'
alias l='ls -l'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias cat='bat'" >> ~/.zshrc