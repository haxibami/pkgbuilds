#!/usr/bin/env bash

# Read PKGBUILD and extract the pkgname, pkgver and description

echo -e "|pkgname|ver|published|desc|\n|---|---|---|---|"

fd -t f -d 2 --no-ignore PKGBUILD | while read -r pkgbuild; do
  source "$pkgbuild"
  echo -e "|$pkgname|$pkgver|no|$pkgdesc|"
done
