#!/bin/bash

echo "☸️ Deploying to Kubernetes"
echo "=========================="
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Get AWS region
AWS_REGION=$(aws configure get region)

# Get EKS cluster name from CloudFormation
echo "🔍 Getting EKS cluster name..."
EKS_CLUSTER_NAME=$(aws cloudformation describe-stacks \
  --stack-name abc-retail-devops \
  --query 'Stacks[0].Outputs[?OutputKey==`EKSClusterName`].OutputValue' \
  --output text 2>/dev/null)

if [ -z "$EKS_CLUSTER_NAME" ] || [ "$EKS_CLUSTER_NAME" = "None" ]; then
    echo "❌ Could not find EKS cluster. Please run ./deploy-infrastructure.sh first."
    exit 1
fi

echo "☸️ EKS Cluster: $EKS_CLUSTER_NAME"

# Update kubeconfig
echo ""
echo "🔧 Updating kubeconfig..."
aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME

if [ $? -ne 0 ]; then
    echo "❌ Failed to update kubeconfig. Please check your AWS credentials."
    exit 1
fi

echo "✅ Kubeconfig updated successfully!"

# Check cluster connectivity
echo ""
echo "🔍 Testing cluster connectivity..."
kubectl cluster-info

if [ $? -ne 0 ]; then
    echo "❌ Cannot connect to cluster. Please check your AWS credentials and cluster status."
    exit 1
fi

# Create namespace if it doesn't exist
echo ""
echo "📁 Creating namespace..."
kubectl create namespace abc-retail --dry-run=client -o yaml | kubectl apply -f -

# Deploy application
echo ""
echo "🚀 Deploying application..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yml

if [ $? -eq 0 ]; then
    echo "✅ Application deployed successfully!"
    
    # Wait for deployment to be ready
    echo ""
    echo "⏳ Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/abc-retail-deployment -n abc-retail
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment is ready!"
        
        # Get service information
        echo ""
        echo "📋 Service Information:"
        echo "======================="
        
        # Get service details
        kubectl get service abc-retail-service -n abc-retail
        
        # Get pod details
        echo ""
        echo "📦 Pod Information:"
        echo "==================="
        kubectl get pods -n abc-retail
        
        # Get Load Balancer URL
        echo ""
        echo "🌐 Getting Load Balancer URL..."
        ALB_URL=$(kubectl get service abc-retail-service -n abc-retail -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
        
        if [ -n "$ALB_URL" ]; then
            echo "✅ Application is accessible at: http://$ALB_URL"
        else
            echo "⏳ Load Balancer is still provisioning..."
            echo "Please wait a few minutes and check again with:"
            echo "kubectl get service abc-retail-service -n abc-retail"
        fi
        
        echo ""
        echo "📝 Useful Commands:"
        echo "==================="
        echo "Check pods: kubectl get pods -n abc-retail"
        echo "Check logs: kubectl logs -f deployment/abc-retail-deployment -n abc-retail"
        echo "Check service: kubectl get service abc-retail-service -n abc-retail"
        echo "Describe pod: kubectl describe pod -n abc-retail"
        
    else
        echo "❌ Deployment failed to become ready. Check pod status:"
        kubectl get pods -n abc-retail
        kubectl describe deployment abc-retail-deployment -n abc-retail
    fi
else
    echo "❌ Failed to deploy application. Please check the errors above."
    exit 1
fi 