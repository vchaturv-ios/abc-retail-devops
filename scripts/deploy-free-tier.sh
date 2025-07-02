#!/bin/bash

echo "🆓 ABC Retail DevOps - AWS Free Tier Deployment"
echo "==============================================="
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed. Please install Ansible first."
    echo "   pip install ansible"
    exit 1
fi

# Install required Ansible collections
echo "📦 Installing Ansible collections..."
ansible-galaxy collection install amazon.aws

echo ""
echo "🚀 Deploying Free Tier Infrastructure..."

# Deploy free tier infrastructure
ansible-playbook aws/aws-free-tier-setup.yml

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Free Tier infrastructure deployed successfully!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Update inventory/hosts with the server IPs shown above"
    echo "2. Run: ./build-and-push-free.sh"
    echo "3. Run: ./deploy-app-free.sh"
    echo ""
    echo "💰 COST: $0 (All services are within AWS Free Tier limits)"
    echo ""
    echo "📝 Important Notes:"
    echo "- Using t2.micro instances (FREE TIER)"
    echo "- No EKS cluster (using local Kubernetes instead)"
    echo "- No load balancer (direct access to instances)"
    echo "- All services will be FREE for 12 months"
else
    echo "❌ Free Tier deployment failed. Please check the errors above."
    exit 1
fi 