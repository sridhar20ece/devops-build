#!/bin/bash

SERVER=$1         # EC2 IP
IMAGE=$2          # Full image name
PORT=$3           # App port
SSH_KEY=$4        # Path to private key file

if [[ -z "$SERVER" || -z "$IMAGE" || -z "$PORT" || -z "$SSH_KEY" ]]; then
    echo "Usage: ./deploy.sh <server-ip> <image> <port> <ssh-key>"
    exit 1
fi

echo "Deploying $IMAGE to $SERVER..."

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@$SERVER "
    docker pull $IMAGE &&
    docker stop app || true &&
    docker rm app || true &&
    docker run -d -p $PORT:$PORT --name app $IMAGE
"

echo "---------------------------------------"
echo "Deployment Completed!"
