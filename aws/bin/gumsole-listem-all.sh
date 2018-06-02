#!/bin/bash


for bucket in gumsole.com test.gumsole.com stage.gumsole.com
do
  echo ""
  echo "Bucket: $bucket"
  aws s3 ls "$bucket"
done
