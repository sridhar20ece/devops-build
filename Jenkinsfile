pipeline {
    agent any

    environment {
        // Optional: you can define environment variables here if needed
        DOCKER_IMAGE_NAME = "myapp"  // Change as per your image name
        DOCKER_TAG = "latest"        // Or you can dynamically use GIT commit
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "Making build.sh executable..."
                sh 'chmod +x build.sh'

                echo "Running build.sh script..."
                sh './build.sh'
            }
        }
    }

    post {
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed.'
        }
    }
}
