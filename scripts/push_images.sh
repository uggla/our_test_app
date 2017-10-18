#!/bin/bash

# Push images to docker hub

ACCOUNT=uggla

docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

for i in $(docker images | grep ourtestapp | awk '{print $1}')
do
    docker tag $i $ACCOUNT/$i
    docker push $ACCOUNT/$i &
done

wait
