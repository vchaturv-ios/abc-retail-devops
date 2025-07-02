#!/bin/bash

echo "🚀 Setting up Jenkins Pipeline and Credentials"
echo "=============================================="

# Jenkins container ID
CONTAINER_ID="79b2e2bfa09a"
JENKINS_URL="http://34.228.11.74:8080"

echo "📋 Setting up Docker Hub credentials..."

# Create Docker Hub credentials in Jenkins
ssh -i abc-retail-free-key.pem ec2-user@34.228.11.74 << 'JENKINS_CREDS'
# Wait for Jenkins to be fully ready
sleep 10

# Create Docker Hub credentials
docker exec 79b2e2bfa09a java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth admin:admin123 create-credentials-by-xml system::system::jenkins _ < /dev/stdin << 'CREDS_XML'
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl plugin="credentials@2.6.2">
  <scope>GLOBAL</scope>
  <id>dockerhub-creds</id>
  <description>Docker Hub credentials for ABC Retail project</description>
  <username>vchaturvdocker</username>
  <password>your-dockerhub-password</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
CREDS_XML

echo "Docker Hub credentials created!"
JENKINS_CREDS

echo "📋 Creating Jenkins Pipeline..."

# Create the pipeline job
ssh -i abc-retail-free-key.pem ec2-user@34.228.11.74 << 'JENKINS_PIPELINE'
# Create the pipeline job
docker exec 79b2e2bfa09a java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth admin:admin123 create-job abc-retail-pipeline-fixed < /tmp/../jenkins/create-jenkins-pipeline.xml

echo "Pipeline job created successfully!"
JENKINS_PIPELINE

echo ""
echo "🎉 Jenkins Pipeline Setup Complete!"
echo "=================================="
echo ""
echo "📋 Access Information:"
echo "======================"
echo "🔧 Jenkins: http://34.228.11.74:8080 (admin/admin123)"
echo "📊 Pipeline: http://34.228.11.74:8080/job/abc-retail-pipeline-fixed/"
echo "🌐 Application: http://107.21.169.207:8080"
echo "📈 Monitoring: http://34.229.169.187:3000 (admin/admin123)"
echo ""
echo "📝 Next Steps:"
echo "1. Go to Jenkins and update Docker Hub credentials with your actual password"
echo "2. Run the pipeline manually or set up webhook triggers"
echo "3. Monitor the deployment through Jenkins and Grafana"
echo ""
echo "🔄 CI/CD Pipeline Flow:"
echo "1. Code Push → Jenkins Pipeline Triggered"
echo "2. Build & Test → Maven compile & test"
echo "3. Docker Build → Create container image"
echo "4. Docker Push → Push to Docker Hub"
echo "5. Deploy → Ansible deploys to app server"
echo "6. Health Check → Verify application is running"
echo "7. Monitor → Update Prometheus configuration"
echo ""
echo "💰 COST: $0 (All services are within AWS Free Tier limits)" 