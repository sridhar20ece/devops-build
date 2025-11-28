pipeline {
    agent any

    stages {

        stage("Detect Branch") {
            steps {
                script {
                    def branch = env.BRANCH_NAME ?: env.GIT_BRANCH ?: sh(
                        script: "git rev-parse --abbrev-ref HEAD",
                        returnStdout: true
                    ).trim()

                    echo "Raw branch detected: ${branch}"

                    branch = branch.replaceAll("origin/", "").trim()
                    echo "Normalized branch: ${branch}"

                    if (!(branch in ["dev", "master", "prod"])) {
                        error "❌ Only dev, master, or prod allowed."
                    }

                    env.ACTUAL_BRANCH = branch
                }
            }
        }

        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("List Workspace") {
            steps {
                sh 'ls -R'
            }
        }

        stage("Build Image") {
            steps {
                sh """
                    chmod +x build.sh
                    BRANCH_NAME=${env.ACTUAL_BRANCH} ./build.sh
                """
            }
        }

        stage("Docker Login") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds01',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
        }

        stage("Push Image") {
            steps {
                sh """
                    IMAGE=\$(cat image.txt)
                    echo "Pushing \$IMAGE"
                    docker push \$IMAGE
                """
            }
        }

        stage("Deploy using deploy.sh") {
            when { expression { env.ACTUAL_BRANCH == "dev" } }
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'dev-server-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh """
                        chmod +x deploy.sh
                        IMAGE=\$(cat image.txt)
                        ./deploy.sh 172.31.22.3 \$IMAGE 80 \$SSH_KEY
                    """
                }
            }
        }
 

        script {
           env.IMAGE = sh(script: "cat image.txt | tr -d '\\n'", returnStdout: true).trim()
           echo "Using IMAGE = ${env.IMAGE}"
        }
        stage("Deploy using docker-compose") {
            when { expression { env.ACTUAL_BRANCH == "dev" } }
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'dev-server-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    script {
                        def remoteHost = "ubuntu@172.31.22.3"

                        sh """
                            echo "📌 Copying docker-compose.yml to remote server..."
                            scp -i \$SSH_KEY -o StrictHostKeyChecking=no docker-compose.yml ${remoteHost}:/home/ubuntu/

                            echo "📌 Deploying latest Docker image via docker-compose..."
                            ssh -i \$SSH_KEY -o StrictHostKeyChecking=no ${remoteHost} '
                                cd /home/ubuntu &&
                                echo "📌 Pulling latest image..." &&
                                IMAGE=$IMAGE docker compose pull &&

                                echo "📌 Restarting containers..." &&
                                IMAGE=$IMAGE docker compose up -d &&

                                echo "✔ Deployment completed successfully."
                            '
                        """
                    }
                }
            }
        }

    }

    post {
        success { echo "✔ Build, push & deploy completed successfully" }
        failure { echo "❌ Pipeline failed" }
    }
}
