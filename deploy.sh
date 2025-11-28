#!/bin/bash

SERVER=$1         # EC2 IP
IMAGE=$2          # Full image name from build.sh
PORT=$3           # Port (optional but kept)
SSH_KEY=$4        # Path to private key file

if [[ -z "$SERVER" || -z "$IMAGE" || -z "$SSH_KEY" ]]; then
    echo "Usage: ./deploy.sh <server-ip> <image> <port> <ssh-key>"
    exit 1
fi

echo "Deploying $IMAGE to $SERVER..."

# 1️⃣ Copy docker-compose.yml to server
echo "📌 Copying docker-compose.yml to server..."
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no docker-compose.yml ubuntu@$SERVER:/home/ubuntu/

# 2️⃣ Deploy using docker compose
echo "📌 Starting deployment on server..."

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@$SERVER "
    cd /home/ubuntu &&
    echo \"📌 Setting IMAGE environment variable\" &&
    export IMAGE=$IMAGE &&

    echo \"📌 Pulling latest image...\" &&
    docker compose pull &&

    echo \"📌 Restarting application...\" &&
    docker compose up -d &&

    echo \"✔ Deployment completed successfully.\"
"

echo "---------------------------------------"
echo "Deployment Completed!"
