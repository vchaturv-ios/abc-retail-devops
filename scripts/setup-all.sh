#!/bin/bash
set -e

# === CONFIGURATION ===
APP_NAME="abc-retail-app"
DOCKER_IMAGE="vchaturvdocker/abc-retail-app:latest"
K8S_DIR="k8s"

echo "🚀 ABC Retail DevOps - Complete Setup Script"
echo "=============================================="

# === CHECK DEPENDENCIES ===
echo "[STEP 0] Checking dependencies..."

command -v docker >/dev/null 2>&1 || { echo >&2 "❌ Docker is not installed. Please install Docker."; exit 1; }
echo "✅ Docker found: $(docker --version)"

command -v kubectl >/dev/null 2>&1 || { echo >&2 "❌ kubectl is not installed. Please install kubectl."; exit 1; }
echo "✅ kubectl found: $(kubectl version --client)"

# Check if k3s is running locally
if command -v k3s >/dev/null 2>&1; then
    echo "✅ k3s found locally"
elif kubectl cluster-info >/dev/null 2>&1; then
    echo "✅ Kubernetes cluster is accessible"
else
    echo "⚠️  Warning: No local k3s found and kubectl cluster not accessible"
    echo "   Make sure you have a Kubernetes cluster running or k3s installed"
fi

# === BUILD DOCKER IMAGE ===
echo ""
echo "[STEP 1] Building Docker image..."
if [ ! -f "docker/Dockerfile" ]; then
    echo "❌ Dockerfile not found in docker directory"
    exit 1
fi

docker build -t $DOCKER_IMAGE .
echo "✅ Docker image built successfully: $DOCKER_IMAGE"

# === PUSH DOCKER IMAGE ===
echo ""
echo "[STEP 2] Pushing Docker image to Docker Hub..."
echo "⚠️  Make sure you're logged into Docker Hub (docker login)"
docker push $DOCKER_IMAGE
echo "✅ Docker image pushed successfully"

# === DEPLOY TO KUBERNETES ===
echo ""
echo "[STEP 3] Deploying to Kubernetes..."

if [ ! -d "$K8S_DIR" ]; then
    echo "❌ Kubernetes manifests directory not found: $K8S_DIR"
    exit 1
fi

# Apply all Kubernetes manifests
kubectl apply -f $K8S_DIR/
echo "✅ Kubernetes manifests applied"

# Wait for deployment to be ready
echo ""
echo "[STEP 4] Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME -n default || {
    echo "⚠️  Deployment not ready within 5 minutes, checking status..."
    kubectl get pods -l app=$APP_NAME
    kubectl describe deployment $APP_NAME
}

# Get service information
echo ""
echo "[STEP 5] Service Information:"
kubectl get services -l app=$APP_NAME

# Get pod status
echo ""
echo "[STEP 6] Pod Status:"
kubectl get pods -l app=$APP_NAME

echo ""
echo "🎉 [DONE] Application deployed to Kubernetes!"
echo ""
echo "📋 Next Steps:"
echo "   1. Check your service NodePort or LoadBalancer for external access"
echo "   2. For Jenkins CI/CD, use: ./scripts/setup-jenkins-pipeline.sh"
echo "   3. For monitoring setup, use: ./scripts/setup-monitoring.sh <monitoring-server-ip> <ssh-key-path>"
echo ""
echo "🔍 Useful Commands:"
echo "   kubectl get pods -l app=$APP_NAME"
echo "   kubectl logs -l app=$APP_NAME"
echo "   kubectl get services -l app=$APP_NAME"
echo "   kubectl describe service $APP_NAME" 