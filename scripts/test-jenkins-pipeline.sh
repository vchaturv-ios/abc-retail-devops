#!/bin/bash
set -e

echo "🧪 Testing Jenkins CI/CD Pipeline"
echo "================================="

# Configuration
JENKINS_IP="34.228.11.74"
JENKINS_URL="http://$JENKINS_IP:8080"
JENKINS_USER="admin"
JENKINS_PASS="admin123"
CONTAINER_ID="79b2e2bfa09a"
SSH_KEY="abc-retail-free-key.pem"

echo "📋 Step 1: Installing Ansible and Kubernetes collection on Jenkins server..."

ssh -i "$SSH_KEY" ec2-user@$JENKINS_IP << 'ANSIBLE_SETUP'
# Install Ansible
sudo yum update -y
sudo yum install -y python3-pip
sudo pip3 install ansible

# Install Kubernetes collection
ansible-galaxy collection install community.kubernetes

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "✅ Ansible and kubectl installed successfully"
ANSIBLE_SETUP

echo "📋 Step 2: Setting up Jenkins credentials..."

# Prompt for Docker Hub password
read -s -p "Enter your Docker Hub password: " DOCKER_PASSWORD
echo

# Create Docker Hub credentials
ssh -i "$SSH_KEY" ec2-user@$JENKINS_IP << EOF
docker exec $CONTAINER_ID java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth $JENKINS_USER:$JENKINS_PASS create-credentials-by-xml system::system::jenkins _ << 'CREDS_XML'
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl plugin="credentials@2.6.2">
  <scope>GLOBAL</scope>
  <id>dockerhub-creds</id>
  <description>Docker Hub credentials for ABC Retail project</description>
  <username>vchaturvdocker</username>
  <password>$DOCKER_PASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
CREDS_XML
EOF

echo "✅ Docker Hub credentials created"

echo "📋 Step 3: Setting up kubeconfig credential..."

# Copy kubeconfig from k3s server to Jenkins
ssh -i "$SSH_KEY" ec2-user@107.21.169.207 "sudo cat /etc/rancher/k3s/k3s.yaml" > /tmp/kubeconfig

# Create kubeconfig credential in Jenkins
ssh -i "$SSH_KEY" ec2-user@$JENKINS_IP << 'KUBECONFIG_CREDS'
docker exec 79b2e2bfa09a java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth admin:admin123 create-credentials-by-xml system::system::jenkins _ << 'CREDS_XML'
<org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl plugin="plain-credentials@1.8">
  <scope>GLOBAL</scope>
  <id>kubeconfig</id>
  <description>Kubernetes config file for ABC Retail project</description>
  <fileName>kubeconfig</fileName>
  <secretBytes>BASE64_ENCODED_KUBECONFIG</secretBytes>
</org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
CREDS_XML
KUBECONFIG_CREDS

echo "✅ Kubeconfig credential created"

echo "📋 Step 4: Creating/Updating Jenkins Pipeline Job..."

# Create pipeline job configuration
cat > /tmp/pipeline-config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@1309.vd2294d3341a_f">
  <description>ABC Retail CI/CD Pipeline with Ansible</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@3697.vb_490d892783b_">
    <script>pipeline {
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
            post {
                always {
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                    junit 'target/surefire-reports/*.xml'
                }
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh "docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_PATH')]) {
                    sh '''
                        ansible-playbook ansible/deploy-k8s.yml \
                          -e new_image=${DOCKER_IMAGE} \
                          -e kubeconfig_path=$KUBECONFIG_PATH
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    sh '''
                        sleep 30
                        curl -f http://107.21.169.207:30080 || exit 1
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
            echo "🌐 Application URL: http://107.21.169.207:30080"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
        always {
            cleanWs()
        }
    }
}</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

# Create/Update the pipeline job
ssh -i "$SSH_KEY" ec2-user@$JENKINS_IP << 'PIPELINE_SETUP'
docker exec 79b2e2bfa09a java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth admin:admin123 create-job abc-retail-pipeline-fixed < /tmp/pipeline-config.xml || \
docker exec 79b2e2bfa09a java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth admin:admin123 update-job abc-retail-pipeline-fixed < /tmp/pipeline-config.xml
PIPELINE_SETUP

echo "✅ Jenkins Pipeline job created/updated"

echo "📋 Step 5: Running the Pipeline..."

# Trigger the pipeline
ssh -i "$SSH_KEY" ec2-user@$JENKINS_IP << 'RUN_PIPELINE'
docker exec 79b2e2bfa09a java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth admin:admin123 build abc-retail-pipeline-fixed
RUN_PIPELINE

echo ""
echo "🎉 Pipeline Testing Setup Complete!"
echo "=================================="
echo ""
echo "📋 Access Information:"
echo "======================"
echo "🔧 Jenkins: $JENKINS_URL (admin/admin123)"
echo "📊 Pipeline: $JENKINS_URL/job/abc-retail-pipeline-fixed/"
echo "🌐 Application: http://107.21.169.207:30080"
echo "📈 Monitoring: http://34.229.169.187:3000 (admin/admin123)"
echo ""
echo "📝 Monitoring the Pipeline:"
echo "1. Go to Jenkins: $JENKINS_URL"
echo "2. Navigate to: abc-retail-pipeline-fixed"
echo "3. Click on the latest build to see progress"
echo "4. Check console output for detailed logs"
echo ""
echo "🔍 Troubleshooting:"
echo "- If Docker login fails: Check Docker Hub credentials"
echo "- If Ansible fails: Check if kubeconfig is accessible"
echo "- If deployment fails: Check Kubernetes cluster status"
echo ""
echo "🚀 Your CI/CD pipeline is now ready for testing!" 