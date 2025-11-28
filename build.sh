#!/bin/bash
SERVER_IP=$1
SSH_USER=$2
SSH_KEY=$3

IMAGE=$(cat image.txt)

echo "Deploying $IMAGE to $SERVER_IP"

ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@$SERVER_IP <<EOF

    echo "Pulling image..."
    docker pull $IMAGE

    echo "Stopping old container..."
    docker rm -f devapp || true

    echo "Starting new container..."
    docker run -d --name devapp -p 80:80 $IMAGE

EOF
