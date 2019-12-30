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

function mergenvs() {
  echo "$@" | xargs -n 1 conda list -e -n | sed "/^#.*$/d" | sort | uniq
}

function bqf() {
  cat $1 | bq query
}

function mdpdf() {
  pandoc -t latex -o $1.pdf $1.md && xdg-open $1.pdf & disown
}

# Does not allow for passing scripts in via process-substitution
# because proc-sub uses pipes, not tmp-file.
#
# To do this, you'll have to create tmp-file yourself and echo the name.
function edcat() {
  filename="$1"

  mutex=/tmp/edcatmutex
  while test -f $mutex; do
    :
  done

  touch $mutex
  $EDITOR "$filename" </dev/tty >/dev/tty;
  rm $mutex

  if test -f "$filename"; then
    if [ "$2" == "-n" ]; then
      echo "$filename"
    else
      cat "$filename"

      if [ "$2" == "-c" ]; then
        rm "$filename"
      fi;
    fi;
  else
    echo ""
  fi;
}

function edcatt() {
  edcat "$(mktemp -u /tmp/edcat.XXXXXXX.$1)" $2
}

function edcats() {
  filename=$(edcat "$(mktemp -u /tmp/edcat.XXXXXXX.$1)" -n)
  chmod a+x $filename
  echo $filename
}

# Open configuration files
function edc() {
  vim -p $(for f in $(cat ~/.dotfiles); do echo ~/$f; done) ~/.bashrc ~/.bash_noport ~/.vim_noport.vim ~/.vim_vundle_noport.vim
}
function sec() {
  cat $HOME/.dotfiles | dmenu -l $(wc -l $HOME/.dotfiles | cut -f1 -d ' ')
}

# Todo:
# Script to find all matching files/dirs, create symlinks to all of them and
# place them in a new directory.
