#!/bin/sh

# absolute_path [fpath]
# some_path must exist
function absolute_path {
  if [[ "$1" == '.' ]] ; then
    echo "$PWD"
    return 0
  fi

  fpath="$1"
  fname=
  if [[ ! -d "$fpath" ]] ; then
    fname="/$(basename "$fpath")"
    fpath="$(dirname "$fpath")"
  fi
  fpath="$(cd "$fpath" && echo "$PWD")"

  echo "$fpath$fname"
}
