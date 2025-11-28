#!/bin/bash

DOCKER_USER="sipserver"

# Detect branch from Jenkins or Git
if [[ -n "$BRANCH_NAME" && "$BRANCH_NAME" != "null" ]]; then
    BRANCH="$BRANCH_NAME"
else
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

# Auto tag using timestamp
TAG=$(date +%s)

echo "Current Branch: $BRANCH"

# Select Docker repo based on branch
if [[ "$BRANCH" == "dev" ]]; then
    IMAGE="$DOCKER_USER/devrepo:$TAG"

elif [[ "$BRANCH" == "master" || "$BRANCH" == "prod" ]]; then
    IMAGE="$DOCKER_USER/prodrepo:$TAG"

else
    echo "❌ Unknown branch: $BRANCH"
    echo "Only 'dev' or 'master/prod' branches are allowed."
    exit 1
fi

echo "Building Docker Image: $IMAGE"
docker build -t "$IMAGE" .

# Export image tag for Jenkins pipeline
echo "$IMAGE" > image.txt
echo "Progress to Complete..................."
echo "$$$$$$$$$$$$####@@@@@@@@@@@@@@@@@@@$$$$$$$$$$$$$$$$$$$$$$"
echo "✔ Build Completed!"
echo "✔ Image saved to image.txt"
