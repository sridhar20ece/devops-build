pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "sipserver2021@gmail.com"
        DOCKER_HUB_CRED = "dockerhub-pass"    // Jenkins Credentials ID
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: "${BRANCH_NAME}",
                    url: 'https://github.com/sridhar20ece/devops-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building image for branch: ${BRANCH_NAME}"
                    sh "chmod +x build.sh"
                    sh "./build.sh ${BRANCH_NAME}"
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([string(credentialsId: DOCKER_HUB_CRED, variable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "${DOCKER_HUB_USER}" --password-stdin
                    '''
                }
            }
        }

stage('Push Docker Image') {
    steps {
        script {
            def IMAGE = readFile('image_tag.txt').trim()
            echo "Pushing Docker image: ${IMAGE}"

            sh "docker push ${IMAGE}"

            echo "Tagging latest..."
            sh """
                BASE_IMAGE=\$(echo ${IMAGE} | cut -d':' -f1)
                docker tag ${IMAGE} \$BASE_IMAGE:latest
                docker push \$BASE_IMAGE:latest
            """
        }
    }
}

        stage('Deploy Container') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'main'
                }
            }
            steps {
                script {
                    def IMAGE = readFile('image_tag.txt').trim()
                    echo "Deploying container using image: ${IMAGE}"
                    sh "chmod +x deploy.sh"
                    sh "./deploy.sh ${IMAGE}"
                }
            }
        }
    }
}
