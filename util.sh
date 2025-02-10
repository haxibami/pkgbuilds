#!/usr/bin/env bash

shopt -s lastpipe

pkgbuilds=$(fd -t f -d 2 'PKGBUILD')

function checksums() {
  echo "==> Updating checksums"
  echo "$pkgbuilds" | xargs -P"$(nproc)" -I@ updpkgsums @
  echo "  -> Checksums updated"
}

function readme() {
  echo "==> Updating README.md"
  table="|pkgname|ver|published|desc|\n|---|---|---|---|"

  for pkgbuild in $pkgbuilds; do
    source "$pkgbuild"
    table="$table\n|$pkgname|$pkgver|no|$pkgdesc|"
  done

  sed -i '/<!-- start -->/,/<!-- end -->/c<!-- start -->\n\n'"$table"'\n\n<!-- end -->' README.md
  echo "  -> README.md updated"
}

function repos() {
  function prepare_repo() {
    target=$(dirname "$1")

    cd "$target" || exit

    # Copy files to the AUR package directory
    mkdir -p "$target"
    fd -t f -d 1 | xargs -P"$(nproc)" -I@ cp -p @ "$target"

    # Generate .SRCINFO
    cd "$target" || exit
    makepkg --printsrcinfo >.SRCINFO
    cd ../..
  }

  export -f prepare_repo

  echo "==> Preparing AUR repos"
  echo "$pkgbuilds" | xargs -P"$(nproc)" -I@ bash -c 'prepare_repo @'
  echo "  -> AUR repos prepared"
}

function cleanup() {
  function cleanup_repo() {
    function remove_unmanaged() {
      comm -23 <(fd -t f -d 1 --no-ignore | sort) <(fd -t f -d 1 | sort) | while read -r file; do
        echo "  -> Removing unmanaged file: $file"
        rm -f "$file"
      done
    }

    target=$(dirname "$1")
    cd "$target" || exit
    remove_unmanaged
    mkdir -p "$target"
    cd "$target" || exit
    remove_unmanaged
    cd ../..
  }

  export -f cleanup_repo

  echo "==> Cleaning up"
  echo "$pkgbuilds" | xargs -P"$(nproc)" -I@ bash -c 'cleanup_repo @'
  echo "  -> Cleaned up"
}

if [[ $# -eq 0 ]]; then
  checksums
  readme
  repos
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case $1 in
  -s | --checksums)
    checksums
    shift
    ;;
  -r | --readme)
    readme
    shift
    ;;
  -p | --prepare)
    repos
    shift
    ;;
  -c | --cleanup)
    cleanup
    shift
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done
