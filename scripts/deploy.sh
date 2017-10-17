#!/bin/bash

# Deploy script
# staging will go on Digital Ocean
# prod will go on openstack on premice

KEYNAME="uggla"
IMAGE="Debian 8 - Docker"
FLAVOR="vps-ssd-1"


echo "$1 phase"

cd scripts
source ./openrc.sh
export OS_PASSWORD="$OS_PASSWORD"
openstack server list

echo "Commit: $TRAVIS_COMMIT"

# Build the instances
openstack server create --image "$IMAGE" --flavor "$FLAVOR" --key-name "$KEYNAME" d1_$TRAVIS_COMMIT
openstack server create --image "$IMAGE" --flavor "$FLAVOR" --key-name "$KEYNAME" d2_$TRAVIS_COMMIT
openstack server create --image "$IMAGE" --flavor "$FLAVOR" --key-name "$KEYNAME" d3_$TRAVIS_COMMIT --wait

# Get the ips
d1ip=$(openstack server show d1_$TRAVIS_COMMIT -f json | jq -r '.[] | select(.Field | contains("addresses"))'.Value | awk -F ',' '{print $NF}' | sed -r 's/\s//g')
d2ip=$(openstack server show d2_$TRAVIS_COMMIT -f json | jq -r '.[] | select(.Field | contains("addresses"))'.Value | awk -F ',' '{print $NF}' | sed -r 's/\s//g')
d3ip=$(openstack server show d3_$TRAVIS_COMMIT -f json | jq -r '.[] | select(.Field | contains("addresses"))'.Value | awk -F ',' '{print $NF}' | sed -r 's/\s//g')

echo "Intance:IPs"
echo "d1:$d1ip"
echo "d2:$d2ip"
echo "d3:$d3ip"

# Remove host keys
ssh-keygen -R $d1ip
ssh-keygen -R $d2ip
ssh-keygen -R $d3ip

sleep 10s
# Try to connect each instance
#ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
ssh -o StrictHostKeyChecking=no debian@$d1ip uname -a
ssh -o StrictHostKeyChecking=no debian@$d2ip uname -a
ssh -o StrictHostKeyChecking=no debian@$d3ip uname -a
ssh -o StrictHostKeyChecking=no debian@$d1ip sudo whoami

# Building small 3 nodes cluster
ssh -o StrictHostKeyChecking=no debian@$d1ip sudo docker swarm init
jointokencmd=$(ssh -o StrictHostKeyChecking=no debian@$d1ip sudo docker swarm join-token worker)
jointokencmd=$(echo $jointokencmd | awk -F 'command: ' '{print $NF}' | sed -r 's/ \\ / /g')

ssh -o StrictHostKeyChecking=no debian@$d2ip sudo $jointokencmd
ssh -o StrictHostKeyChecking=no debian@$d3ip sudo $jointokencmd
