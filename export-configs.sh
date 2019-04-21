#!/bin/bash

REPO=$HOME/davidrv-dotfiles

cp $HOME/.bash_aliases $HOME/.bash_functions $HOME/.bash_misc $HOME/.inputrc $HOME/.tmux.conf $HOME/.vimrc $REPO
cp $HOME/.config/i3/config.base $REPO/.config/i3/config.base
cp $HOME/.config/zathura/zathurarc $REPO/.config/zathura/zathurarc
cp -r $HOME/.vim/after/* $REPO/.vim/after/
