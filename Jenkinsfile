pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run build.sh') {
            steps {
                sh """
                    chmod +x build.sh
                    BRANCH_NAME=${env.BRANCH_NAME} ./build.sh
                """
            }
        }

        stage('Docker Login') {
            when {
                expression { fileExists('image.txt') }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                 usernameVariable: 'USER',
                                                 passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
        }

        stage('Push Image') {
            when {
                expression { fileExists('image.txt') }
            }
            steps {
                sh '''
                    IMAGE=$(cat image.txt)
                    docker push $IMAGE
                '''
            }
        }
    }
}
