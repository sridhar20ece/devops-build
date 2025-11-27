pipeline {
    agent any

    environment {
        DOCKER_USER = credentials('dockerhub-user')
        DOCKER_PASS = credentials('dockerhub-pass')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    BRANCH = env.GIT_BRANCH.replace("origin/", "")
                    echo "Building for branch: ${BRANCH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "./build.sh ${BRANCH}"
            }
        }

        stage('Docker Login') {
            steps {
                sh """
                echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    IMAGE_TAG = sh(
                        script: "cat image_tag.txt",
                        returnStdout: true
                    ).trim()

                    sh "docker push ${IMAGE_TAG}"
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
            sh "docker logout"
        }
    }
}
