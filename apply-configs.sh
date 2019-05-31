#!/bin/bash

REPO=$HOME/davidrv-dotfiles

cp $REPO/.bash_aliases $REPO/.bash_functions $REPO/.bash_misc $REPO/.inputrc $REPO/.tmux.conf $REPO/.vimrc $HOME
cp -r $REPO/.bash_completion.d/* $HOME/.bash_completion.d/
cp $REPO/.config/i3/config.base $HOME/.config/i3/config.base
cp $REPO/.config/zathura/zathurarc $HOME/.config/zathura/zathurarc
cp -r $REPO/.vim/after/* $HOME/.vim/after/
