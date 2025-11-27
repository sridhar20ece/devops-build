#!/bin/bash

DOCKER_USER="sipserver"

# Use Jenkins env var if available
if [[ -n "$BRANCH_NAME" ]]; then
    BRANCH="$BRANCH_NAME"
else
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

# Auto tag using timestamp
TAG=$(date +%s)

echo "Current Branch: $BRANCH"

if [[ "$BRANCH" == "dev" ]]; then
    IMAGE="$DOCKER_USER/devrepo:$TAG"
elif [[ "$BRANCH" == "master" || "$BRANCH" == "prod" ]]; then
    IMAGE="$DOCKER_USER/prodrepo:$TAG"
else
    echo "Unknown branch. Only dev and master are supported."
    exit 1
fi

echo "Building Docker Image: $IMAGE"

docker build -t $IMAGE .
echo "$IMAGE" > image.txt
