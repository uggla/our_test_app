#!/bin/bash

# Deploy script
# staging will go on Digital Ocean
# prod will go on openstack on premice
echo "$1 phase"
source scripts/openrc.sh
export OS_PASSWORD="$OS_PASSWORD"
openstack server list

echo "Commit: $TRAVIS_COMMIT"

openstack server create --image 'Debian 8 - Docker' --flavor "vps-ssd-1" --key-name uggla d1_$TRAVIS_COMMIT
