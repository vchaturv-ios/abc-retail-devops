import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

// Create admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin123")
Jenkins.instance.setSecurityRealm(hudsonRealm)

// Create authorization strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
Jenkins.instance.setAuthorizationStrategy(strategy)

// Save configuration
Jenkins.instance.save()

// Create pipeline job
def job = Jenkins.instance.createProject(WorkflowJob.class, "abc-retail-pipeline-fixed")

// Define pipeline script
def pipelineScript = '''
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "vchaturvdocker/abc-retail-app:latest"
        GIT_REPO = "https://github.com/vchaturv-ios/abc-retail-devops.git"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${env.GIT_REPO}"
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
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
        
        stage('Deploy to Application Server') {
            steps {
                sh 'ansible-playbook -i inventory/hosts deploy-docker.yml'
            }
        }
        
        stage('Health Check') {
            steps {
                sh 'curl -f http://107.21.169.207:8080/actuator/health || exit 1'
            }
        }
    }
    
    post {
        success {
            echo "Pipeline completed successfully!"
            sh 'curl -X POST http://34.229.169.187:9090/-/reload'
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
'''

job.setDefinition(new CpsFlowDefinition(pipelineScript, true))
job.save()

println "Jenkins pipeline job created successfully!"
