pipeline {
    agent any

    environment {
        DEV_REPO = "sipserver/devrepo"
        DOCKER_CREDENTIALS = "dockerhub-creds01"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Triggered by branch: ${env.GIT_BRANCH}"
            }
        }

        stage('Validate Branch') {
            steps {
                script {
                    if (!env.GIT_BRANCH.endsWith("/dev")) {
                        error "This pipeline only builds when dev branch is updated. Current branch: ${env.GIT_BRANCH}"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'chmod +x build.sh'
                sh './build.sh dev'
            }
        }

        stage('Push to Docker Hub (DEV)') {
            steps {
                script {
                    def imageTag = readFile('image_tag.txt').trim()

                    echo "Pushing DEV image: ${imageTag}"

                    withCredentials([usernamePassword(
                        credentialsId: env.DOCKER_CREDENTIALS,
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker push ${imageTag}
                        """
                    }
                }
            }
        }

    }

    post {
        success {
            echo "✔ DEV image built & pushed successfully!"
        }
        failure {
            echo "❌ Build failed!"
        }
    }
}
