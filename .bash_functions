#!/bin/bash

function cl() {
  cd $1

  # If cd didn't fail, then ls
  if [ $? -eq 0 ]; then
    ls
  fi
}

function md() {
  if [ "$1" != "" ]; then
    mkdir -p "$1"
  fi
  cd "$1"
}

function lt() {
  if [ $# -eq 0 ]
    then
      lt */
  fi

  for d in "$@"; do tree -l $d; done
}

function vimext() {
  for e in "$@"; do
    echo "Editing all $e files"

    files=$(find . -name "*.$e")

    # Iff at least one file exists, open all files
    if ! [ -z "$files" ]
    then
      vim -p $files;
    fi
  done
}

# Open configuration files
function edc() {
  vim -p ~/.bashrc ~/.bash_aliases ~/.bash_functions ~/.bash_misc ~/.inputrc ~/.bash_noport ~/.vimrc ~/.vim/after/* ~/.vim_noport.vim ~/.vim_vundle_noport.vim ~/.tmux.conf ~/.config/i3/config ~/.config/zathura/zathurarc
}

# Todo:
# Script to find all matching files/dirs, create symlinks to all of them and
# place them in a new directory.
