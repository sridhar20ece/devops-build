pipeline {
    agent any

    environment {
        DOCKER_USER = "sipserver"
        DEV_IP = "<DEV_EC2_PUBLIC_IP>"
        PROD_IP = "<PROD_EC2_PUBLIC_IP>"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "./build.sh"
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    IMAGE = sh(script: "cat image.txt", returnStdout: true).trim()
                    BRANCH = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()

                    if (BRANCH == "dev") {
                        sh "docker push ${IMAGE}"
                    }

                    if (BRANCH == "master") {
                        sh "docker push ${IMAGE}"
                        sh """
                           docker tag ${IMAGE} ${DOCKER_USER}/prodrepo:latest
                           docker push ${DOCKER_USER}/prodrepo:latest
                           """
                    }
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                script {
                    IMAGE = sh(script: "cat image.txt", returnStdout: true).trim()
                    BRANCH = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()

                    if (BRANCH == "dev") {
                        sh "./deploy.sh ${DEV_IP} ${IMAGE} 3000"
                    }

                    if (BRANCH == "master") {
                        sh "./deploy.sh ${PROD_IP} ${IMAGE} 80"
                    }
                }
            }
        }
    }
}
