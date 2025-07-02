#!/bin/bash

echo "🎯 ABC Retail DevOps Project Configuration"
echo "=========================================="
echo ""

# Get user inputs
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your AWS region (e.g., us-east-1): " AWS_REGION
read -p "Enter your AWS account ID: " AWS_ACCOUNT_ID

echo ""
echo "📝 Updating configuration files..."

# Update Docker Hub username in all files
echo "🔧 Updating Docker Hub username..."
sed -i "s/YOUR_DOCKERHUB_USERNAME/$DOCKERHUB_USERNAME/g" k8s/deployment.yaml
sed -i "s/YOUR_DOCKERHUB_USERNAME/$DOCKERHUB_USERNAME/g" deploy-docker.yml
sed -i "s/YOUR_DOCKERHUB_USERNAME/$DOCKERHUB_USERNAME/g" Jenkinsfile

# Update GitHub username
echo "🔧 Updating GitHub username..."
sed -i "s/YOUR_GITHUB_USERNAME/$GITHUB_USERNAME/g" Jenkinsfile

# Update AWS region in CloudFormation template
echo "🔧 Updating AWS region..."
sed -i "s/us-east-1/$AWS_REGION/g" aws-cloudformation-template.yml
sed -i "s/us-east-1/$AWS_REGION/g" aws-setup.yml
sed -i "s/us-east-1/$AWS_REGION/g" aws-eks-setup.yml
sed -i "s/us-east-1/$AWS_REGION/g" aws-iam-setup.yml

# Update AWS account ID
echo "🔧 Updating AWS account ID..."
sed -i "s/{{ aws_account_id }}/$AWS_ACCOUNT_ID/g" aws-eks-setup.yml
sed -i "s/{{ aws_account_id }}/$AWS_ACCOUNT_ID/g" aws-iam-setup.yml

echo ""
echo "✅ Configuration updated successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Deploy AWS infrastructure: ./deploy-infrastructure.sh"
echo "2. Update inventory/hosts with actual server IPs"
echo "3. Build and push Docker image: ./build-and-push.sh"
echo "4. Deploy to Kubernetes: ./deploy-to-k8s.sh"
echo ""
echo "📁 Configuration Summary:"
echo "   Docker Hub: $DOCKERHUB_USERNAME"
echo "   GitHub: $GITHUB_USERNAME"
echo "   AWS Region: $AWS_REGION"
echo "   AWS Account: $AWS_ACCOUNT_ID" 