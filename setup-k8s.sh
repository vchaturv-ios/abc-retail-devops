#!/bin/bash

echo "🚀 Setting up Kubernetes (k3s) for ABC Retail application..."

# Application server IP
APP_SERVER_IP="107.21.169.207"

echo "📋 Installing k3s on application server..."

# Install k3s on the application server
ssh -i abc-retail-free-key.pem ec2-user@$APP_SERVER_IP << 'EOF'
# Install k3s
curl -sfL https://get.k3s.io | sh -

# Wait for k3s to be ready
echo "⏳ Waiting for k3s to be ready..."
sleep 30

# Check k3s status
sudo systemctl status k3s

# Get kubeconfig
sudo cat /etc/rancher/k3s/k3s.yaml
EOF

echo "✅ k3s installed on application server"

# Copy Kubernetes manifests to the server
echo "📤 Copying Kubernetes manifests..."
scp -i abc-retail-free-key.pem -r k8s/ ec2-user@$APP_SERVER_IP:/tmp/

# Deploy the application to Kubernetes
echo "🚀 Deploying ABC Retail application to Kubernetes..."
ssh -i abc-retail-free-key.pem ec2-user@$APP_SERVER_IP << 'EOF'
# Set KUBECONFIG
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Create namespace
kubectl apply -f /tmp/k8s/namespace.yaml

# Deploy application
kubectl apply -f /tmp/k8s/deployment.yaml
kubectl apply -f /tmp/k8s/service.yaml

# Wait for deployment
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/abc-retail-app -n abc-retail

# Check deployment status
echo "📊 Deployment status:"
kubectl get pods -n abc-retail
kubectl get services -n abc-retail

# Get the NodePort
NODEPORT=$(kubectl get service abc-retail-service -n abc-retail -o jsonpath='{.spec.ports[0].nodePort}')
echo "🌐 Application accessible at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):$NODEPORT"
EOF

echo ""
echo "🎯 Kubernetes deployment completed!"
echo "📊 Check your application at: http://$APP_SERVER_IP:30080"
echo ""
echo "🔧 Useful commands:"
echo "  - View pods: ssh -i abc-retail-free-key.pem ec2-user@$APP_SERVER_IP 'kubectl get pods -n abc-retail'"
echo "  - View services: ssh -i abc-retail-free-key.pem ec2-user@$APP_SERVER_IP 'kubectl get services -n abc-retail'"
echo "  - View logs: ssh -i abc-retail-free-key.pem ec2-user@$APP_SERVER_IP 'kubectl logs -f deployment/abc-retail-app -n abc-retail'"
echo ""
echo "🏆 Your project now includes Kubernetes deployment! (35 marks) 🎉" 