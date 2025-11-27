pipeline {
    agent any

    environment {
        DOCKER_USER = "sipserver"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Running build.sh to build Docker image..."
                sh 'chmod +x build.sh'
                sh './build.sh'
                
                script {
                    IMAGE = readFile('image.txt').trim()
                    echo "Docker image built: ${IMAGE}"
                }
            }
        }

        stage('Push Docker Image') {
            when {
                expression {
                    return env.BRANCH_NAME == 'dev' || env.BRANCH_NAME == 'master'
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh "echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin"
                    sh "docker push ${IMAGE}"
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace..."
            sh 'docker system prune -f || true'
        }
        success {
            echo "Pipeline completed successfully."
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
