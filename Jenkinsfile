pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "sipserver2021@gmail.com"
        DOCKER_HUB_CRED = "dockerhub-creds01"   // Jenkins Credentials ID
    }

    stages {

        stage('Checkout Code') {
            steps {
                // Checkout main/dev automatically depending on webhook
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${env.GIT_BRANCH ?: 'main'}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/sridhar20ece/devops-build.git',
                        credentialsId: 'git_PAT01'
                    ]]
                ])
            }
        }

        stage('Determine Branch') {
            steps {
                script {
                    BRANCH_NAME = sh(
                        script: "git rev-parse --abbrev-ref HEAD",
                        returnStdout: true
                    ).trim()

                    echo "Detected branch: ${BRANCH_NAME}"
                }
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
                        BASE_IMAGE=$(echo ${IMAGE} | cut -d':' -f1)
                        docker tag ${IMAGE} $BASE_IMAGE:latest
                        docker push $BASE_IMAGE:latest
                    """
                }
            }
        }

        stage('Deploy Container') {
            when {
                anyOf {
                    branch "main"
                    branch "dev"
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
