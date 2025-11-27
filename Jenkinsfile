pipeline {
    agent any

    // Define parameters for the pipeline
    parameters {
        string(name: 'BRANCH_TO_BUILD', defaultValue: 'dev', description: 'Branch to build: dev or main')
    }

    environment {
        DEV_REPO = "sipserver/devrepo"
        PROD_REPO = "sipserver/prodrepo"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code for branch: ${params.BRANCH_TO_BUILD}"
                // Checkout the branch passed as parameter
                checkout([$class: 'GitSCM',
                    branches: [[name: "${params.BRANCH_TO_BUILD}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/sridhar20ece/devops-build.git',
                        credentialsId: 'git_PAT01'
                    ]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Making build.sh executable..."
                sh 'chmod +x build.sh'

                echo "Running build.sh script..."
                // Pass the branch parameter to build.sh
                sh "./build.sh ${params.BRANCH_TO_BUILD}"
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
