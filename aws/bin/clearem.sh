#!/bin/bash

# Walk through the list and assume all are buckets that will
# be cleared

# WARNING! This is DANGEROUS!
while [ $# -gt 0 ]
do
  bucket="$1"
  echo "EXEC: aws s3 rm s3:// $bucket --recursive"
  aws s3 rm s3://"$bucket" --recursive
  shift
done
