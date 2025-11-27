pipeline {
    agent any

    stages {

        stage("Detect Branch") {
            steps {
                script {
                    // Detect branch from Jenkins env or git
                    def branch = env.BRANCH_NAME ?: env.GIT_BRANCH ?: sh(
                        script: "git rev-parse --abbrev-ref HEAD",
                        returnStdout: true
                    ).trim()

                    echo "Raw branch detected: ${branch}"

                    // Remove "origin/" if present
                    branch = branch.replaceAll("origin/", "").trim()

                    echo "Normalized branch: ${branch}"

                    if (branch != "dev" && branch != "master") {
                        error "❌ Only dev or master allowed."
                    }

                    env.ACTUAL_BRANCH = branch
                }
            }
        }

        stage("Checkout") {
            steps {
                checkout scm
            }
        }
        stage('List Workspace') {
            steps {
               sh 'ls -R'
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
