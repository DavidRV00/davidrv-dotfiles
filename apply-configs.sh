#!/bin/bash

REPO_DOTFILES_DIR="$HOME/davidrv-dotfiles/dotfiles"

read -p "This will overwrite system config files. Are you sure? (Y/y to confirm): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  for f in $(cat $REPO_DOTFILES_DIR/.dotfiles); do
      mkdir -pv $HOME/$(dirname "$f") &&
      cp -rTv $REPO_DOTFILES_DIR/$f $HOME/$f;
  done
fi
