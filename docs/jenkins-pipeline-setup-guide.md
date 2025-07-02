# Jenkins Pipeline Setup Guide

## Step 1: Access Jenkins
- **URL**: http://34.228.11.74:8080
- **Username**: admin
- **Password**: admin123

## Step 2: Create New Pipeline Job

1. **Click "New Item"** on the Jenkins dashboard
2. **Enter job name**: `abc-retail-pipeline-fixed`
3. **Select "Pipeline"** and click "OK"

## Step 3: Configure Pipeline

### General Settings:
- **Description**: `ABC Retail DevOps CI/CD Pipeline`

### Pipeline Configuration:
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: `https://github.com/vchaturv-ios/abc-retail-devops.git`
- **Branch**: `main`
- **Script Path**: `Jenkinsfile`

### OR Use Pipeline Script (if SCM doesn't work):

**Definition**: Pipeline script

**Script Content**:
```groovy
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
                git branch: 'main', url: "${env.GIT_REPO}"
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
            echo '🎉 Pipeline completed successfully!'
            echo 'Application deployed and accessible at: http://107.21.169.207:8080'
            echo 'Monitoring available at: http://34.229.169.187:3000'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
        always {
            echo '🧹 Cleaning up workspace...'
            cleanWs()
        }
    }
}
```

## Step 4: Set Up Docker Hub Credentials

1. **Go to**: Manage Jenkins → Credentials → System → Global credentials
2. **Click**: "Add Credentials"
3. **Kind**: Username with password
4. **Scope**: Global
5. **ID**: `dockerhub-creds`
6. **Description**: `Docker Hub credentials for ABC Retail project`
7. **Username**: `vchaturvdocker`
8. **Password**: Your Docker Hub password
9. **Click**: "Create"

## Step 5: Install Required Plugins

1. **Go to**: Manage Jenkins → Manage Plugins
2. **Install these plugins**:
   - Docker Pipeline
   - Ansible
   - Credentials Binding
   - Git Integration

## Step 6: Run the Pipeline

1. **Go to**: Dashboard → abc-retail-pipeline-fixed
2. **Click**: "Build Now"
3. **Monitor**: The build progress in real-time

## Step 7: Verify Deployment

- **Application**: http://107.21.169.207:8080
- **Jenkins**: http://34.228.11.74:8080
- **Prometheus**: http://34.229.169.187:9090
- **Grafana**: http://34.229.169.187:3000 (admin/admin123)

## Troubleshooting

### If Pipeline Fails:
1. Check Jenkins logs for specific errors
2. Verify Docker Hub credentials are correct
3. Ensure all required plugins are installed
4. Check if the application server is accessible

### If Build Fails:
1. Check Maven dependencies
2. Verify Java version compatibility
3. Check Docker build context

## Success Indicators

✅ Pipeline job appears in Jenkins dashboard  
✅ Build completes successfully  
✅ Application is accessible at http://107.21.169.207:8080  
✅ Monitoring shows application metrics  
✅ All stages complete without errors 