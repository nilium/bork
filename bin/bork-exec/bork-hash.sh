#!/bin/sh

function hash_file {
  hash_result=`openssl dgst -sha1 "$1"`
  r=$?
  if [[ $r == 0 ]] ; then
    echo ${hash_result#*\= }
  fi
  return $r
}
