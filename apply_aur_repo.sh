#!/usr/bin/env bash

# run in root directory

DIRS=$(find ./* -maxdepth 0 -type d)

for dir in $DIRS; do
  cd $dir
  cp * $dir
  cd $dir
  makepkg --printsrcinfo > .SRCINFO
  cd ../..
done
