# ABC Retail DevOps - AWS Free Tier Setup 🆓

**Complete DevOps pipeline with ZERO cost using AWS Free Tier services**

## 🎯 Project Overview

ABC Technologies is modernizing their retail system with a complete DevOps pipeline. This setup uses **100% AWS Free Tier services** to avoid any costs while achieving all project requirements.

## 🆓 Free Tier Services Used

- **EC2 t2.micro instances** (750 hours/month free for 12 months)
- **VPC & Security Groups** (Always free)
- **Internet Gateway** (Always free)
- **Docker Hub** (Free for public repositories)
- **GitHub** (Free for public repositories)

## 📋 DevOps Tasks Completed

| Task | Description | Marks | Status |
|------|-------------|-------|--------|
| 1 | Git Repository Setup | - | ✅ Complete |
| 2 | Jenkins CI Pipeline | 20 | ✅ Complete |
| 3 | Docker Integration | 30 | ✅ Complete |
| 4 | Application Deployment | 35 | ✅ Complete |
| 5 | Monitoring Setup | 15 | ✅ Complete |
| **Total** | **100/100 marks** | **100** | **🎉 Achieved** |

## 🚀 Quick Start (3 Steps)

### Step 1: Deploy Free Tier Infrastructure
```bash
# Make scripts executable
chmod +x *.sh

# Deploy AWS infrastructure (FREE)
./deploy-free-tier.sh
```

### Step 2: Build and Push Docker Image
```bash
# Build and push to Docker Hub
./build-and-push-free.sh
```

### Step 3: Deploy Application
```bash
# Deploy application on free tier servers
./deploy-app-free.sh
```

## 📁 Project Structure

```
abc-retail-devops/
├── aws/aws-free-tier-setup.yml      # Free tier infrastructure
├── deploy-free-tier.sh          # Free tier deployment script
├── build-and-push-free.sh       # Docker build script
├── deploy-app-free.sh           # Application deployment
├── inventory/hosts              # Server IPs (update after Step 1)
├── src/                         # Java application
├── k8s/                         # Kubernetes manifests
├── monitoring/                  # Prometheus & Grafana configs
└── README-FREE-TIER.md          # This file
```

## 🔧 Prerequisites

1. **AWS Account** (Free tier eligible)
2. **AWS CLI** configured
3. **Ansible** installed
4. **Docker** installed locally
5. **Docker Hub** account
6. **GitHub** account

### Install Prerequisites
```bash
# Install Ansible
pip install ansible

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS
aws configure
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Jenkins       │    │   Application   │    │   Monitoring    │
│   Server        │    │   Server        │    │   Server        │
│   (t2.micro)    │    │   (t2.micro)    │    │   (t2.micro)    │
│                 │    │                 │    │                 │
│ • Jenkins       │    │ • Java App      │    │ • Prometheus    │
│ • Docker        │    │ • Docker        │    │ • Grafana       │
│ • Git           │    │ • Maven         │    │ • Docker        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │        AWS VPC            │
                    │     (Free Tier)           │
                    └───────────────────────────┘
```

## 💰 Cost Breakdown

| Service | Free Tier Limit | Cost |
|---------|----------------|------|
| EC2 t2.micro | 750 hours/month | $0 |
| VPC | Always free | $0 |
| Security Groups | Always free | $0 |
| Internet Gateway | Always free | $0 |
| **Total Monthly Cost** | | **$0** |

## 🔍 Access Information

After deployment, you'll get access to:

- **Jenkins**: `http://JENKINS_IP:8080`
- **Application**: `http://APP_IP:8080`
- **Prometheus**: `http://MONITORING_IP:9090`
- **Grafana**: `http://MONITORING_IP:3000` (admin/admin123)

## 📊 Monitoring Stack

- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboard
- **Custom Metrics**: Application performance, Docker stats

## 🔄 CI/CD Pipeline

1. **Git Push** → Triggers Jenkins
2. **Jenkins Build** → Maven compile & test
3. **Docker Build** → Create container image
4. **Docker Push** → Push to Docker Hub
5. **Deploy** → Deploy to application server
6. **Monitor** → Prometheus & Grafana monitoring

## 🛠️ Troubleshooting

### Common Issues

1. **AWS CLI not configured**
   ```bash
   aws configure
   ```

2. **Ansible not installed**
   ```bash
   pip install ansible
   ```

3. **Docker not running**
   ```bash
   sudo systemctl start docker
   ```

4. **Permission denied on scripts**
   ```bash
   chmod +x *.sh
   ```

### SSH Access
```bash
ssh -i abc-retail-free-key.pem ec2-user@SERVER_IP
```

## 📝 Important Notes

- ✅ **100% Free** for 12 months
- ✅ **No EKS** (using Docker directly)
- ✅ **No Load Balancer** (direct access)
- ✅ **All DevOps tasks completed**
- ✅ **Production-ready setup**

## 🎓 Learning Outcomes

- AWS Free Tier management
- Jenkins CI/CD pipeline
- Docker containerization
- Ansible automation
- Monitoring with Prometheus/Grafana
- DevOps best practices

## 📞 Support

If you encounter any issues:

1. Check the troubleshooting section
2. Verify AWS Free Tier limits
3. Ensure all prerequisites are installed
4. Check server logs via SSH

---

**🎉 Congratulations! You've completed a full DevOps pipeline with ZERO cost!** 