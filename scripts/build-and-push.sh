#!/bin/bash

echo "🐳 Building and Pushing Docker Image"
echo "===================================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Get Docker Hub username from deployment file
DOCKERHUB_USERNAME=$(grep -o 'YOUR_DOCKERHUB_USERNAME' k8s/deployment.yaml | head -1)
if [ "$DOCKERHUB_USERNAME" = "YOUR_DOCKERHUB_USERNAME" ]; then
    echo "❌ Please run ./configure-project.sh first to set your Docker Hub username."
    exit 1
fi

# Get the actual username from the file
DOCKERHUB_USERNAME=$(grep -o '[^/]*/abc-retail-app' k8s/deployment.yaml | cut -d'/' -f1)

echo "🔍 Docker Hub Username: $DOCKERHUB_USERNAME"
echo ""

# Build the Java application
echo "🔨 Building Java application..."
mvn clean package

if [ $? -ne 0 ]; then
    echo "❌ Maven build failed. Please check the errors above."
    exit 1
fi

echo "✅ Java application built successfully!"

# Build Docker image
echo ""
echo "🐳 Building Docker image..."
docker build -t $DOCKERHUB_USERNAME/abc-retail-app:latest .

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed. Please check the errors above."
    exit 1
fi

echo "✅ Docker image built successfully!"

# Check if user is logged in to Docker Hub
if ! docker info | grep -q "Username"; then
    echo ""
    echo "🔐 Please login to Docker Hub:"
    docker login
fi

# Push to Docker Hub
echo ""
echo "📤 Pushing to Docker Hub..."
docker push $DOCKERHUB_USERNAME/abc-retail-app:latest

if [ $? -eq 0 ]; then
    echo "✅ Docker image pushed successfully!"
    echo ""
    echo "🌐 Image available at: https://hub.docker.com/r/$DOCKERHUB_USERNAME/abc-retail-app"
    echo ""
    echo "📝 Next step: Run ./deploy-to-k8s.sh"
else
    echo "❌ Failed to push Docker image. Please check your Docker Hub credentials."
    exit 1
fi 