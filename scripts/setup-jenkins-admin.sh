#!/bin/bash

echo "🔧 Setting up Jenkins Admin User and Pipeline"
echo "=============================================="

# Jenkins container ID
CONTAINER_ID="79b2e2bfa09a"
JENKINS_URL="http://34.228.11.74:8080"

echo "📋 Jenkins Access Information:"
echo "URL: $JENKINS_URL"
echo "Initial Admin Password: 859e6725dc9e4569aa681d00fbd8d26b"
echo ""
echo "📝 Instructions:"
echo "1. Go to: $JENKINS_URL"
echo "2. Enter the initial admin password: 859e6725dc9e4569aa681d00fbd8d26b"
echo "3. Choose 'Install suggested plugins'"
echo "4. Create admin user with username: admin, password: admin123"
echo "5. Complete the setup"
echo ""
echo "🔧 After Jenkins setup, run the following to create the pipeline:"
echo ""
echo "SSH into Jenkins server:"
echo "ssh -i abc-retail-free-key.pem ec2-user@34.228.11.74"
echo ""
echo "Then run:"
echo "docker exec $CONTAINER_ID java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth admin:admin123 create-job abc-retail-pipeline-fixed < /tmp/pipeline-config.xml"
echo ""
echo "📊 Pipeline will be available at: $JENKINS_URL/job/abc-retail-pipeline-fixed/" 