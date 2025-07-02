pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vchaturvdocker/abc-retail-app:latest"
        GIT_REPO = "https://github.com/vchaturv-ios/abc-retail-devops.git"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: "${env.GIT_REPO}"
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Deploy to Application Server') {
            steps {
                script {
                    sh '''
                        # Deploy to application server
                        ssh -i /tmp/abc-retail-free-key.pem -o StrictHostKeyChecking=no ec2-user@107.21.169.207 "
                            docker stop abc-retail-app || true
                            docker rm abc-retail-app || true
                            docker pull ${DOCKER_IMAGE}
                            docker run -d --name abc-retail-app -p 8080:8080 ${DOCKER_IMAGE}
                        "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
