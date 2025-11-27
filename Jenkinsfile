pipeline {
    agent any

    stages {

        stage("Checkout") {
            steps {
                echo "Checking out code..."
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${env.BRANCH_NAME}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/sridhar20ece/devops-build.git',
                        credentialsId: 'git_PAT01'
                    ]]
                ])
            }
        }

        stage("Detect Branch") {
            steps {
                script {
                    def BRANCH = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    echo "Detected branch after checkout: ${BRANCH}"

                    if (BRANCH != "dev" && BRANCH != "prod") {
                        error "❌ Not allowed. Only dev or prod branch can trigger this pipeline."
                    }

                    env.ACTUAL_BRANCH = BRANCH
                }
            }
        }

        stage("Build Image") {
            steps {
                sh "chmod +x build.sh"
                sh "./build.sh ${env.ACTUAL_BRANCH}"
            }
        }

        stage("Push to Docker Hub") {
            steps {
                script {
                    def imageTag = readFile("image_tag.txt").trim()
                    echo "Pushing Docker image: ${imageTag}"

                    withCredentials([usernamePassword(
                        credentialsId: "dockerhub-creds01",
                        usernameVariable: "DOCKER_USER",
                        passwordVariable: "DOCKER_PASS"
                    )]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${imageTag}"
                    }
                }
            }
        }
    }

    post {
        success { echo "✔ Successfully built and pushed image!" }
        failure { echo "❌ Pipeline failed." }
    }
}
