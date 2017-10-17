#!/bin/bash

# Remove all staging instances
openstack server delete $(openstack server list -f json | jq -r .[].ID)
