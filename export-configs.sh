#!/bin/bash

REPO_DOTFILES_DIR="$HOME/davidrv-dotfiles/dotfiles"

rm -rfv $REPO_DOTFILES_DIR
mkdir -pv $REPO_DOTFILES_DIR

for f in $(cat $HOME/.dotfiles); do
    mkdir -pv $REPO_DOTFILES_DIR/$(dirname "$f") &&
    cp -rv $HOME/$f $REPO_DOTFILES_DIR/$f;
done
