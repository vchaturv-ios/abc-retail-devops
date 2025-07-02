# ABC Retail DevOps Project

A comprehensive DevOps project demonstrating CI/CD pipeline with Jenkins, Docker, Kubernetes, and monitoring using Prometheus and Grafana on AWS.

## Project Structure

```
abc-retail-devops/
├── src/                      # Java application source code
├── docker/                   # Docker configurations
│   ├── Dockerfile            # Application container
│   └── Dockerfile.jenkins    # Jenkins container
├── jenkins/                  # Jenkins pipeline and setup
│   ├── Jenkinsfile           # CI/CD pipeline definition
│   ├── create-jenkins-pipeline.xml
│   └── jenkins-setup.groovy
├── ansible/                  # Ansible automation playbooks
│   ├── deploy-k8s.yml        # Kubernetes deployment
│   └── deploy-docker.yml     # Docker deployment
├── k8s/                      # Kubernetes manifests
├── monitoring/               # Monitoring stack configuration
│   ├── prometheus.yml
│   ├── grafana-dashboard.json
│   └── docker-compose-monitoring.yml
├── aws/                      # AWS infrastructure templates
├── scripts/                  # Automation and setup scripts
├── docs/                     # Project documentation
├── inventory/                # Ansible inventory files
└── pom.xml                   # Maven project configuration
```

## Quick Start

1. **Clone the repository**
2. **Run the complete setup**: `./scripts/setup-all.sh`
3. **Access your services**:
   - Application: http://your-k8s-ip:30080
   - Jenkins: http://your-jenkins-ip:8080 (admin/admin123)
   - Monitoring: http://your-monitoring-ip:3000 (admin/admin123)

## Documentation

- **[Main Documentation](docs/README.md)** - Complete setup and usage guide
- **[Free Tier Setup](docs/README-FREE-TIER.md)** - AWS free tier specific instructions
- **[Jenkins Setup Guide](docs/jenkins-pipeline-setup-guide.md)** - Detailed Jenkins configuration

## Key Features

- **CI/CD Pipeline**: Jenkins with Maven build, Docker image creation, and Kubernetes deployment
- **Containerization**: Docker images for application and Jenkins
- **Orchestration**: Kubernetes deployment with health checks
- **Monitoring**: Prometheus metrics collection and Grafana dashboards
- **Infrastructure as Code**: AWS CloudFormation and Ansible automation
- **Automation**: One-click setup scripts for all components

## Technologies Used

- **Java** - Application backend
- **Maven** - Build tool
- **Docker** - Containerization
- **Jenkins** - CI/CD pipeline
- **Kubernetes (k3s)** - Container orchestration
- **Ansible** - Infrastructure automation
- **Prometheus** - Metrics collection
- **Grafana** - Monitoring dashboards
- **AWS** - Cloud infrastructure

## Support

For detailed setup instructions and troubleshooting, see the [main documentation](docs/README.md).
