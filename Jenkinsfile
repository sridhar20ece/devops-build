
pipeline {
    agent any

    stages {

        stage("Detect Branch") {
            steps {
                script {
                    echo "Webhook triggered by branch: ${env.BRANCH_NAME}"

                    if (env.BRANCH_NAME != "dev" && env.BRANCH_NAME != "prod") {
                        error "❌ Not allowed. Only dev or prod branch can trigger this pipeline."
                    }
                }
            }
        }

        stage("Checkout") {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${env.BRANCH_NAME}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/sridhar20ece/devops-build.git',
                        credentialsId: 'git_PAT01'
                    ]]
                ])
            }
        }

        stage("Build Image") {
            steps {
                sh "chmod +x build.sh"
                sh "./build.sh ${env.BRANCH_NAME}"
            }
        }

        stage("Push to Docker Hub") {
            steps {
                script {
                    def imageTag = readFile("image_tag.txt").trim()

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
