#!/bin/sh

DOTFILES_DIR=$(dirname "$(readlink -f "$0")")

ln -s $DOTFILES_DIR/.aliases ~/.aliases

echo "source ~/.aliases" >> ~/.zshrc
echo "source ~/.aliases" >> ~/.bashrc
