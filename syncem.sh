#!/bin/bash

src=$1
dst=$2
public=''
recurse=''
shift
shift

while [ $# -gt 0 ]
do
  key="$1"
  case $key in
    -p|--public)
      public="--acl public-read"
      ;;

    --dryrun)
      dryrun="--dryrun"
      ;;

    *)
      echo $"Usage: $0 src dst [--public] [--dryrun]"
  esac
  shift
done

echo "EXEC: aws s3 sync $src $dst $public $dryrun"
aws s3 sync $src $dst $public $dryrun
