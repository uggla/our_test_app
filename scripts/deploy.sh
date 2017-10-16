#!/bin/bash

# Deploy script
# staging will go on Digital Ocean
# prod will go on openstack on premice

source script/openrc.sh
export OS_PASSWORD="$OS_PASSWORD"
openstack server list
