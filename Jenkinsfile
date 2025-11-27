pipeline {
    agent any

    stages {

        stage("Detect Branch") {
            steps {
                script {
                    // Detect branch from Git (works for webhook-triggered pipeline jobs)
                    BRANCH = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()

                    echo "Detected branch: ${BRANCH}"

                    // Allow ONLY dev or prod
                    if (BRANCH != "dev" && BRANCH != "prod") {
                        error "❌ Not allowed. Pipeline can run only for dev or prod branch."
                    }

                    // Save branch to environment
                    env.ACTUAL_BRANCH = BRANCH
                }
            }
        }

        stage("Checkout") {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${env.ACTUAL_BRANCH}"]],
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
