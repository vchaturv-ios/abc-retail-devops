pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "vchaturvdocker/abc-retail-app:latest"
        GIT_REPO = "https://github.com/vchaturv-ios/abc-retail-devops.git"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from Git repository...'
                git branch: 'master', url: "${env.GIT_REPO}"
            }
        }
        
        stage('Build & Test') {
            steps {
                echo 'Building Java application with Maven...'
                sh 'mvn clean package'
                echo 'Running tests...'
                sh 'mvn test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
        
        stage('Deploy to Application Server') {
            steps {
                echo 'Deploying application using Ansible...'
                sh 'ansible-playbook -i inventory/hosts deploy-docker.yml'
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                sh 'sleep 30'
                sh 'curl -f http://107.21.169.207:8080/ || exit 1'
                echo 'Health check passed!'
            }
        }
        
        stage('Update Monitoring') {
            steps {
                echo 'Reloading Prometheus configuration...'
                sh 'curl -X POST http://34.229.169.187:9090/-/reload || echo "Prometheus reload failed"'
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo 'Application deployed and accessible at: http://107.21.169.207:8080'
            echo 'Monitoring available at: http://34.229.169.187:3000'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
} 