# ABC Retail DevOps Project - AWS Deployment

**Post Graduate Certification Program in DevOps - Project 1**

Building a CI/CD Pipeline for a Retail Company on AWS using Jenkins, Docker, Ansible, and Kubernetes.

## Project Overview

This project implements a complete CI/CD pipeline for ABC Technologies' retail application on AWS, addressing the business challenges of:
- Low availability
- Low scalability  
- Low performance
- Hard to build and maintain
- Time-consuming development and deployment

## DevOps Technology Stack

- **CI/CD**: Jenkins Pipeline
- **Containerization**: Docker
- **Configuration Management**: Ansible
- **Orchestration**: Amazon EKS (Kubernetes)
- **Monitoring**: Prometheus + Grafana
- **Cloud Platform**: AWS
- **Infrastructure as Code**: CloudFormation

## Project Requirements

### Task Breakdown (100 Marks Total)

1. **Task 1: Git Repository Setup** ✅
   - Push code to GitHub repository
   - Setup version control

2. **Task 2: Jenkins CI Pipeline (20 Marks)** ✅
   - Create continuous integration pipeline
   - Jobs for compile, test, and package
   - Master-slave node setup

3. **Task 3: Docker Integration (30 Marks)** ✅
   - Create Dockerfile
   - Build and push Docker image
   - Integrate with Ansible

4. **Task 4: Kubernetes Deployment (35 Marks)** ✅
   - Deploy to EKS cluster
   - Create pod, service, and deployment manifests
   - Integrate with Ansible

5. **Task 5: Monitoring (15 Marks)** ✅
   - Setup Prometheus for resource monitoring
   - Setup Grafana for dashboards
   - Monitor CPU, Memory, Network metrics

## Project Structure

```
abc-retail-devops/
├── src/                                    # Existing Java application
├── k8s/
│   ├── deployment.yaml                     # Kubernetes deployment
│   └── service.yml                         # Kubernetes service
├── monitoring/
│   ├── prometheus.yml                      # Prometheus configuration
│   └── grafana-dashboard.json              # Grafana dashboard
├── inventory/
│   └── hosts                               # Ansible inventory
├── aws-setup.yml                           # AWS infrastructure setup
├── aws-eks-setup.yml                       # EKS cluster setup
├── aws-iam-setup.yml                       # IAM roles and policies
├── aws-cloudformation-template.yml         # CloudFormation template
├── Dockerfile                              # Docker image configuration
├── Jenkinsfile                             # Jenkins CI/CD pipeline
├── deploy-docker.yml                       # Ansible playbook for Docker
├── deploy-k8s.yml                          # Ansible playbook for Kubernetes
├── setup-monitoring.yml                    # Ansible playbook for monitoring
└── pom.xml                                 # Maven configuration
```

## Prerequisites

### AWS Account Setup
1. **AWS Account**: Active AWS account with billing enabled
2. **AWS CLI**: Installed and configured with appropriate credentials
3. **AWS Permissions**: Admin access or appropriate IAM permissions

### Local Tools
1. **Docker**
2. **Ansible**
3. **kubectl**
4. **AWS CLI**
5. **Git**

## DevOps Deployment Instructions

### Step 1: AWS Infrastructure Setup

#### Using CloudFormation (Recommended)
```bash
# Deploy the complete infrastructure
aws cloudformation create-stack \
  --stack-name abc-retail-devops \
  --template-body file://aws-cloudformation-template.yml \
  --capabilities CAPABILITY_NAMED_IAM

# Monitor deployment
aws cloudformation describe-stack-events \
  --stack-name abc-retail-devops
```

#### Using Ansible
```bash
# Install required Ansible collections
ansible-galaxy collection install amazon.aws
ansible-galaxy collection install kubernetes.core

# Setup infrastructure
ansible-playbook aws-setup.yml
```

### Step 2: Application Containerization

```bash
# Build the existing Java application
mvn clean package

# Build Docker image (update username)
docker build -t yourdockerhubusername/abc-retail-app:latest .

# Push to Docker Hub
docker push yourdockerhubusername/abc-retail-app:latest
```

### Step 3: Kubernetes Deployment

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name abc-retail-cluster-production

# Deploy application
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yml

# Check deployment status
kubectl get pods -n abc-retail
kubectl get services -n abc-retail
```

### Step 4: Jenkins Pipeline Setup

```bash
# Get Jenkins server IP from CloudFormation outputs
aws cloudformation describe-stacks \
  --stack-name abc-retail-devops \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsInstanceId`].OutputValue' \
  --output text

# SSH to Jenkins server
ssh -i abc-retail-key-production.pem ec2-user@JENKINS_IP
```

#### Configure Jenkins
1. **Get initial admin password:**
   ```bash
   sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

2. **Install required plugins:**
   - Docker Pipeline
   - Kubernetes CLI
   - Ansible
   - AWS Credentials

3. **Configure credentials:**
   - Docker Hub credentials
   - AWS credentials
   - SSH keys

4. **Create pipeline job:**
   - Use the provided `Jenkinsfile`
   - Update Docker Hub username

### Step 5: Monitoring Setup

```bash
# Deploy monitoring stack
ansible-playbook -i inventory/hosts setup-monitoring.yml

# Access monitoring
# Prometheus: http://MONITORING_IP:9090
# Grafana: http://MONITORING_IP:3000 (admin/admin123)
```

## AWS Infrastructure Components

### Core AWS Services
- **Amazon EKS**: Managed Kubernetes cluster
- **Amazon EC2**: Compute instances for Jenkins and monitoring
- **Amazon VPC**: Virtual private cloud with public/private subnets
- **Amazon ALB**: Application Load Balancer
- **Amazon IAM**: Identity and access management
- **Amazon CloudWatch**: Monitoring and logging

### Infrastructure Architecture
```
AWS Cloud
├── Public Subnet (Jenkins Server)
├── Private Subnet (EKS Cluster)
├── Monitoring (Prometheus + Grafana)
└── Application Load Balancer
```

## CI/CD Pipeline

The Jenkins pipeline includes:

1. **Checkout**: Git repository checkout
2. **Build & Test**: Maven build with tests
3. **Docker Build**: Create Docker image
4. **Docker Push**: Push to Docker Hub
5. **Ansible Deploy**: Deploy using Ansible
6. **Kubernetes Deploy**: Deploy to EKS cluster

## Monitoring & Observability

### AWS CloudWatch Integration
- **Logs**: Application and infrastructure logs
- **Metrics**: CPU, Memory, Network utilization
- **Alarms**: Automated alerting

### Prometheus & Grafana
- **System Metrics**: CPU, Memory, Network
- **Application Metrics**: Response times, throughput
- **Custom Dashboards**: Business metrics

## Cost Optimization

### Estimated Monthly Costs (us-east-1)
- **EKS Cluster**: ~$150-200
- **EC2 Instances**: ~$100-150
- **Load Balancer**: ~$20-30
- **Data Transfer**: ~$10-20
- **Total**: ~$280-400/month

## Business Benefits

After implementation, ABC Technologies will achieve:

1. **High Availability**: 99.9% uptime with AWS EKS
2. **High Scalability**: Auto-scaling based on demand
3. **High Performance**: Optimized container deployment
4. **Easy Maintenance**: Automated deployment and rollback
5. **Quick Development**: CI/CD pipeline reduces time to market
6. **Lower Production Bugs**: Automated testing
7. **Frequent Releases**: Continuous deployment capability
8. **Better Customer Experience**: Faster response times
9. **Reduced Time to Market**: Streamlined development process
10. **Cost Optimization**: Pay-as-you-use model

## Troubleshooting

### Common AWS Issues

1. **EKS Cluster Issues**
   ```bash
   aws eks describe-cluster --name abc-retail-cluster-production
   ```

2. **EC2 Instance Issues**
   ```bash
   aws ec2 describe-instances --instance-ids i-1234567890abcdef0
   ```

3. **Load Balancer Issues**
   ```bash
   aws elbv2 describe-load-balancers --names abc-retail-alb
   ```

### Application Issues

1. **Pod Issues**
   ```bash
   kubectl logs -f deployment/abc-retail-deployment -n abc-retail
   kubectl describe pod -n abc-retail
   ```

2. **Service Issues**
   ```bash
   kubectl get endpoints -n abc-retail
   kubectl describe service abc-retail-service -n abc-retail
   ```

## Security Best Practices

### AWS Security
- **VPC**: Isolated network environment
- **Security Groups**: Restrictive firewall rules
- **IAM**: Least privilege access
- **Encryption**: Data in transit and at rest
- **Monitoring**: CloudTrail and CloudWatch

## Quick Deployment Script

```bash
#!/bin/bash
# DevOps Tasks Only - ABC Retail Project

echo "🎯 Starting DevOps Tasks for ABC Retail Project..."

# Task 1: Setup AWS Infrastructure
echo "☁️ Task 1: Setting up AWS Infrastructure..."
aws cloudformation create-stack \
  --stack-name abc-retail-devops \
  --template-body file://aws-cloudformation-template.yml \
  --capabilities CAPABILITY_NAMED_IAM

echo "⏳ Waiting for infrastructure..."
aws cloudformation wait stack-create-complete --stack-name abc-retail-devops

# Task 2: Build and Push Docker Image
echo "🐳 Task 2: Docker Integration..."
mvn clean package
docker build -t yourdockerhubusername/abc-retail-app:latest .
docker push yourdockerhubusername/abc-retail-app:latest

# Task 3: Deploy to EKS
echo "☸️ Task 3: Kubernetes Deployment..."
aws eks update-kubeconfig --region us-east-1 --name abc-retail-cluster-production
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yml

# Task 4: Setup Monitoring
echo "📊 Task 4: Monitoring Setup..."
ansible-playbook -i inventory/hosts setup-monitoring.yml

# Task 5: Get Access Information
echo "🔗 Getting access information..."
ALB_URL=$(aws cloudformation describe-stacks \
  --stack-name abc-retail-devops \
  --query 'Stacks[0].Outputs[?OutputKey==`ApplicationLoadBalancerDNS`].OutputValue' \
  --output text)

JENKINS_IP=$(aws cloudformation describe-stacks \
  --stack-name abc-retail-devops \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsInstanceId`].OutputValue' \
  --output text)

echo "✅ DevOps Tasks Complete!"
echo "🌐 Application: http://$ALB_URL"
echo "🔧 Jenkins: http://$JENKINS_IP:8080"
echo "📊 Prometheus: http://$JENKINS_IP:9090"
echo "📈 Grafana: http://$JENKINS_IP:3000 (admin/admin123)"
```

## License

This project is part of the Post Graduate Certification Program in DevOps.

## AWS Resources

- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [Amazon EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
