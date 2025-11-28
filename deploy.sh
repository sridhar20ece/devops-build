#!/bin/bash

SERVER=$1         # EC2 IP
IMAGE=$2          # Full image name
PORT=$3           # App port

if [[ -z "$SERVER" || -z "$IMAGE" || -z "$PORT" ]]; then
    echo "Usage: ./deploy.sh <server-ip> <image> <port>"
    exit 1
fi

echo "Deploying $IMAGE to $SERVER..."

ssh -o StrictHostKeyChecking=no ubuntu@$SERVER "
    docker pull $IMAGE &&
    docker stop app || true &&
    docker rm app || true &&
    docker run -d -p $PORT:$PORT --name app $IMAGE
"
echo "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
echo "Deployment Completed!"
