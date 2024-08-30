#!/usr/bin/env bash

# Read PKGBUILD and extract the pkgname, pkgver and description

echo -e "|pkgname|ver|published|desc|\n|---|---|---|---|"

fd -t f -d 2 --no-ignore PKGBUILD | while read PKGBUILD; do
  source "$PKGBUILD"
  echo -e "|$pkgname|$pkgver|no|$pkgdesc|"
done
