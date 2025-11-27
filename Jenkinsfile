pipeline {
    agent any

    stages {

        stage("Detect Branch") {
            steps {
                script {

                    // Detect branch from multiple possible Jenkins variables
                    def branch = env.BRANCH_NAME ?: env.GIT_BRANCH ?: sh(
                        script: "git rev-parse --abbrev-ref HEAD",
                        returnStdout: true
                    ).trim()

                    echo "Detected branch: ${branch}"

                    if (branch == "HEAD") {
                        error "❌ Cannot detect branch. Check GitHub webhook + Jenkins job type."
                    }

                    // Save branch for later stages
                    env.ACTUAL_BRANCH = branch

                    if (branch != "dev" && branch != "master") {
                        error "❌ Only dev or master allowed."
                    }
                }
            }
        }

        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Build Image") {
            steps {
                sh """
                    chmod +x build.sh
                    BRANCH_NAME=${env.ACTUAL_BRANCH} ./build.sh
                """
            }
        }

        stage("Docker Login") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds01',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
        }

        stage("Push Image") {
            steps {
                sh '''
                    IMAGE=$(cat image.txt)
                    echo "Pushing $IMAGE"
                    docker push $IMAGE
                '''
            }
        }
    }

    post {
        success { echo "✔ Image built & pushed successfully" }
        failure { echo "❌ Pipeline failed" }
    }
}
