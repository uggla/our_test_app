#!/bin/bash

# Deploy script
# staging will go on Digital Ocean
# prod will go on openstack on premice
echo "$1 phase"
echo $(pwd)
source scripts/openrc.sh
export OS_PASSWORD="$OS_PASSWORD"
openstack server list
