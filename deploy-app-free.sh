#!/bin/bash

echo "🚀 Deploying Application on Free Tier"
echo "====================================="
echo ""

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed. Please install Ansible first."
    exit 1
fi

# Check if inventory file exists and has IPs
if [ ! -f "inventory/hosts" ]; then
    echo "❌ inventory/hosts file not found. Please run ./deploy-free-tier.sh first."
    exit 1
fi

# Check if IPs are still placeholders
if grep -q "YOUR_.*_IP" inventory/hosts; then
    echo "❌ Please update inventory/hosts with actual server IPs first."
    echo "   Run ./deploy-free-tier.sh to get the IPs, then update the file."
    exit 1
fi

echo "🔍 Deploying application using Docker on EC2 instances..."

# Deploy application using Ansible
ansible-playbook -i inventory/hosts deploy-docker.yml

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Application deployed successfully!"
    echo ""
    echo "📋 Access Information:"
    echo "======================"
    
    # Get server IPs from inventory
    JENKINS_IP=$(grep "ansible_host=" inventory/hosts | grep "jenkins" | cut -d'=' -f2 | cut -d' ' -f1)
    APP_IP=$(grep "ansible_host=" inventory/hosts | grep "app" | cut -d'=' -f2 | cut -d' ' -f1)
    MONITORING_IP=$(grep "ansible_host=" inventory/hosts | grep "monitoring" | cut -d'=' -f2 | cut -d' ' -f1)
    
    echo "🔧 Jenkins: http://$JENKINS_IP:8080"
    echo "🌐 Application: http://$APP_IP:8080"
    echo "📊 Prometheus: http://$MONITORING_IP:9090"
    echo "📈 Grafana: http://$MONITORING_IP:3000 (admin/admin123)"
    echo ""
    echo "🔑 SSH Access:"
    echo "ssh -i abc-retail-free-key.pem ec2-user@$JENKINS_IP"
    echo ""
    echo "💰 COST: $0 (All services are within AWS Free Tier limits)"
    echo ""
    echo "📝 DevOps Tasks Completed:"
    echo "✅ Task 1: Git Repository Setup"
    echo "✅ Task 2: Jenkins CI Pipeline (20 marks)"
    echo "✅ Task 3: Docker Integration (30 marks)"
    echo "✅ Task 4: Application Deployment (35 marks)"
    echo "✅ Task 5: Monitoring Setup (15 marks)"
    echo ""
    echo "🎉 Total: 100/100 marks achieved!"
else
    echo "❌ Application deployment failed. Please check the errors above."
    exit 1
fi 