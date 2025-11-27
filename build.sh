#!/bin/bash

DOCKER_USER="sipserver"
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Auto tag using timestamp
TAG=$(date +%s)

echo "Current Branch: $BRANCH"

if [[ "$BRANCH" == "dev" ]]; then
    IMAGE="$DOCKER_USER/devrepo:$TAG"
elif [[ "$BRANCH" == "master" ]]; then
    IMAGE="$DOCKER_USER/prodrepo:$TAG"
else
    echo "Unknown branch. Only dev and master are supported."
    exit 1
fi

echo "Building Docker Image: $IMAGE"

docker build -t $IMAGE .
echo "Building Docker Image....!!!!"
echo "============================="
echo "Build Completed!"
echo "$IMAGE" > image.txt   # Export for Jenkins use
