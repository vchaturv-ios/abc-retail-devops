#!/bin/bash

echo "☁️ Deploying AWS Infrastructure for ABC Retail DevOps"
echo "====================================================="
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "🔍 AWS Account ID: $AWS_ACCOUNT_ID"

# Get AWS region
AWS_REGION=$(aws configure get region)
echo "🌍 AWS Region: $AWS_REGION"

echo ""
echo "🚀 Deploying CloudFormation stack..."

# Deploy infrastructure using CloudFormation
aws cloudformation create-stack \
  --stack-name abc-retail-devops \
  --template-body file://aws-cloudformation-template.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters ParameterKey=Environment,ParameterValue=production

if [ $? -eq 0 ]; then
    echo "✅ CloudFormation stack creation initiated successfully!"
    echo "⏳ Waiting for stack to complete..."
    
    # Wait for stack to complete
    aws cloudformation wait stack-create-complete --stack-name abc-retail-devops
    
    if [ $? -eq 0 ]; then
        echo "✅ Infrastructure deployment completed successfully!"
        
        # Get stack outputs
        echo ""
        echo "📋 Infrastructure Details:"
        echo "=========================="
        
        # Get VPC ID
        VPC_ID=$(aws cloudformation describe-stacks \
          --stack-name abc-retail-devops \
          --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' \
          --output text)
        echo "🔗 VPC ID: $VPC_ID"
        
        # Get Public Subnet ID
        PUBLIC_SUBNET_ID=$(aws cloudformation describe-stacks \
          --stack-name abc-retail-devops \
          --query 'Stacks[0].Outputs[?OutputKey==`PublicSubnetId`].OutputValue' \
          --output text)
        echo "🌐 Public Subnet ID: $PUBLIC_SUBNET_ID"
        
        # Get Private Subnet ID
        PRIVATE_SUBNET_ID=$(aws cloudformation describe-stacks \
          --stack-name abc-retail-devops \
          --query 'Stacks[0].Outputs[?OutputKey==`PrivateSubnetId`].OutputValue' \
          --output text)
        echo "🔒 Private Subnet ID: $PRIVATE_SUBNET_ID"
        
        # Get EKS Cluster Name
        EKS_CLUSTER_NAME=$(aws cloudformation describe-stacks \
          --stack-name abc-retail-devops \
          --query 'Stacks[0].Outputs[?OutputKey==`EKSClusterName`].OutputValue' \
          --output text)
        echo "☸️ EKS Cluster Name: $EKS_CLUSTER_NAME"
        
        # Get Jenkins Instance ID
        JENKINS_INSTANCE_ID=$(aws cloudformation describe-stacks \
          --stack-name abc-retail-devops \
          --query 'Stacks[0].Outputs[?OutputKey==`JenkinsInstanceId`].OutputValue' \
          --output text)
        echo "🔧 Jenkins Instance ID: $JENKINS_INSTANCE_ID"
        
        # Get Monitoring Instance ID
        MONITORING_INSTANCE_ID=$(aws cloudformation describe-stacks \
          --stack-name abc-retail-devops \
          --query 'Stacks[0].Outputs[?OutputKey==`MonitoringInstanceId`].OutputValue' \
          --output text)
        echo "📊 Monitoring Instance ID: $MONITORING_INSTANCE_ID"
        
        # Get Load Balancer DNS
        ALB_DNS=$(aws cloudformation describe-stacks \
          --stack-name abc-retail-devops \
          --query 'Stacks[0].Outputs[?OutputKey==`ApplicationLoadBalancerDNS`].OutputValue' \
          --output text)
        echo "🌐 Load Balancer DNS: $ALB_DNS"
        
        # Get Key Pair Name
        KEY_PAIR_NAME=$(aws cloudformation describe-stacks \
          --stack-name abc-retail-devops \
          --query 'Stacks[0].Outputs[?OutputKey==`KeyPairName`].OutputValue' \
          --output text)
        echo "🔑 Key Pair Name: $KEY_PAIR_NAME"
        
        echo ""
        echo "📝 Next Steps:"
        echo "1. Update inventory/hosts with the instance IPs"
        echo "2. Run: ./build-and-push.sh"
        echo "3. Run: ./deploy-to-k8s.sh"
        echo "4. Configure Jenkins at: http://$JENKINS_INSTANCE_ID:8080"
        
    else
        echo "❌ Stack creation failed. Check CloudFormation events."
        aws cloudformation describe-stack-events --stack-name abc-retail-devops
    fi
else
    echo "❌ Failed to create CloudFormation stack."
fi 