pipeline {
    agent any

    environment {
        IMAGE_NAME = "sridhar20ece/devops-build"
    }

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'dev', description: 'Branch to build and deploy (dev or prod)')
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Checking out branch: ${params.BRANCH_NAME}"
                git branch: "${params.BRANCH_NAME}", url: 'https://github.com/sridhar20ece/devops-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "./build.sh ${params.BRANCH_NAME}"
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', 
                                                  usernameVariable: 'DOCKER_USER', 
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${params.BRANCH_NAME}"
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                echo "Deploying Docker container..."
                sh "./deploy.sh ${params.BRANCH_NAME}"
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for branch: ${params.BRANCH_NAME}!"
        }
        failure {
            echo "Pipeline failed. Check logs for branch: ${params.BRANCH_NAME}!"
        }
    }
}
