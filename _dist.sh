#!/usr/bin/env bash

function _dist () {
  cd $1
  mkdir -p $1
  fd -t f -d 1 | xargs -i cp -p {} $1
  cd $1
  makepkg --printsrcinfo > .SRCINFO
  cd ../..
}

_dist $1
