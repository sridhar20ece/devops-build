pipeline {
    agent any

    environment {
        DOCKER_CREDS = credentials('dockerhub-user')   // username + password
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.BRANCH = env.GIT_BRANCH.replace("origin/", "")
                    echo "Building for branch: ${env.BRANCH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "./build.sh ${env.BRANCH}"
            }
        }

        stage('Docker Login') {
            steps {
                sh """
                    echo "${DOCKER_CREDS_PSW}" | docker login -u "${DOCKER_CREDS_USR}" --password-stdin
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = sh(
                        script: "cat image_tag.txt",
                        returnStdout: true
                    ).trim()

                    sh "docker push ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "./deploy.sh"
            }
        }
    }

    post {
        always {
            node {                   // FIX: ensures workspace exists
                sh "docker logout"
            }
        }
    }
}
