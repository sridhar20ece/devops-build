CI/CD Pipeline for Dockerized Application
========================================
Overview
=========

This Jenkins pipeline automates the build, push, and deployment process for a Dockerized application. It supports multiple branches (dev, master, prod) and deploys the application automatically to a target server using deploy.sh.

Pipeline Flow
1. Detect Branch
   =============

Detects the current Git branch.

Normalizes the branch name by removing origin/.

Ensures the branch is one of dev, master, or prod.

Stores the branch in env.ACTUAL_BRANCH for later stages.

2. Checkout
   ========

Checks out the source code from the repository configured in Jenkins.

3. List Workspace
   ==============

Lists the contents of the workspace for debugging purposes.

ls -R

4. Build Docker Image
   ==================

Executes build.sh to build the Docker image.

Passes the branch name to build.sh as an environment variable.

Example:

chmod +x build.sh
BRANCH_NAME=dev ./build.sh


Outputs the image name to image.txt.

5. Docker Login
   ===========

Logs in to Docker Hub using credentials stored in Jenkins (dockerhub-creds01).

echo $PASS | docker login -u $USER --password-stdin

6. Push Docker Image
   ================

Reads the Docker image name from image.txt.

Pushes the image to Docker Hub.

IMAGE=$(cat image.txt)
docker push $IMAGE

7. Load IMAGE Variable
   ==================

Loads the image name into a pipeline environment variable env.IMAGE for deployment.

8. Deploy Using deploy.sh
   ======================

Deploys the application only for the dev branch.

Uses SSH credentials stored in Jenkins (dev-server-ssh-key) to connect to the server (172.31.22.3).

Executes deploy.sh to pull the latest image and run the container.

chmod +x deploy.sh
./deploy.sh 172.31.22.3 $IMAGE 80 $SSH_KEY

Post Actions

On Success: Prints ✔ Build, push & deploy completed successfully.

On Failure: Prints ❌ Pipeline failed.

Prerequisites
==============

Jenkins with Pipeline plugin installed.

Docker installed on both Jenkins node and target server.

SSH access to the target server.

Docker Hub account for image push.

build.sh and deploy.sh scripts in the repository.
