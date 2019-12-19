#!/bin/bash

REPO_DOTFILES_DIR="$HOME/davidrv-dotfiles/dotfiles"

for f in $(cat $REPO_DOTFILES_DIR/.dotfiles); do
    mkdir -pv $HOME/$(dirname "$f") &&
    cp -rTv $REPO_DOTFILES_DIR/$f $HOME/$f;
done
