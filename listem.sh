#!/bin/bash

while [ $# -gt 0 ]
do
  aws s3 ls $1
  shift
done
