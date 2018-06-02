#!/bin/bash

./ec2.py > /tmp/ec2-inventory.json
aws s3 cp /tmp/ec2-inventory.json s3://in.gumsole.com/ec2-inventory.json

