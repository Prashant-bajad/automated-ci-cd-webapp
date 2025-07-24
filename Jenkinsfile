pipeline {
    agent any

    environment {
        // Replace with your Docker Hub username
        DOCKERHUB_USERNAME = 'prashantbajad01'
        // Replace with your GitHub repository name (e.g., automated-ci-cd-webapp)
        REPO_NAME = 'automated-ci-cd-webapp'
        // Replace with your EC2 Public IP
        EC2_IP = '3.80.36.82'
        // Credential ID for Docker Hub (jo hum baad mein banayenge)
        DOCKERHUB_CRED_ID = 'dockerhub-cred'
        // Credential ID for GitHub (jo abhi banaya hai)
        GITHUB_CRED_ID = 'github-credential-id' // Ye woh ID hai jo tumne Step 23 mein di thi
        // Path to the SSH key file inside the Jenkins container
        EC2_KEY_PATH = '/var/jenkins_home/mykeyy.pem'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    // Use the 'usernamePassword' binding for GitHub authentication
                    // 'GITHUB_CRED_ID' should be the ID of your 'Username with password' credential in Jenkins
                    // 'username' will be your GitHub username, and 'password' will be your GitHub PAT
                    withCredentials([usernamePassword(credentialsId: env.GITHUB_CRED_ID, usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        git branch: 'main',
                            credentialsId: env.GITHUB_CRED_ID, // Use the credential ID here too
                            url: "https://github.com/${env.GIT_USERNAME}/${env.REPO_NAME}.git"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image using the Dockerfile in the current directory
                    sh "docker build -t ${env.DOCKERHUB_USERNAME}/${env.REPO_NAME}:latest ."
                }
            }
        }

        stage('Docker Login and Push') {
                steps {
                    script {
                        withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CRED_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                            // Modified line: Use double quotes for the echo command, and ensure variables are properly expanded.
                            sh """
                                echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                                docker push ${env.DOCKERHUB_USERNAME}/${env.REPO_NAME}:latest
                            """
                        }
                    }
                }
            }

        stage('Deploy to EC2') {
                steps {
                    script {
                        sshagent(credentials: ['ec2-ssh-key']) { // 'ec2-ssh-key' is the credential ID
                            sh """
                                ssh -o StrictHostKeyChecking=no ubuntu@${env.EC2_IP} << 'EOF'
                                  echo "Stopping existing container..."
                                  docker stop ${env.REPO_NAME} || true
                                  echo "Removing existing container..."
                                  docker rm ${env.REPO_NAME} || true
                                  echo "Pulling new Docker image..."
                                  docker pull ${env.DOCKERHUB_USERNAME}/${env.REPO_NAME}:latest
                                  echo "Running new container..."
                                  docker run -d --name ${env.REPO_NAME} -p 80:80 ${env.DOCKERHUB_USERNAME}/${env.REPO_NAME}:latest
                                  echo "Deployment complete!"
EOF
                            """
                        }
                    }
                }
            }

    post {
        always {
            // Clean up Docker login session
            sh "docker logout"
            // Clean up workspace
            cleanWs()
        }
        success {
            echo 'Pipeline finished successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
