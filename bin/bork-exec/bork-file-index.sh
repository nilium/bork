#!/bin/sh

station="$(bork station)"

# index_for_hash file_hash [station_path]
function index_for_hash {
  hash_path="index/${1:0:2}/${1:2:${#1}}"
  if [[ -n $2 ]] ; then
    hash_path="$2/$hash_path"
  fi
  echo "$hash_path"
}
