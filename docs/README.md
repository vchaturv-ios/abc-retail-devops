# ABC Retail DevOps Project

## Overview
This project demonstrates a complete DevOps pipeline for a Java application using:
- **GitHub** for source code management
- **Jenkins** for CI/CD
- **Docker** for containerization
- **Kubernetes (k3s on AWS EC2)** for deployment
- **Prometheus & Grafana** for monitoring
- **Ansible** for deployment and infrastructure automation

## Project Structure
```
abc-retail-devops/
├── src/                   # Java source code
├── docker/
│   ├── Dockerfile             # For building the app image
│   └── Dockerfile.jenkins     # For Jenkins container
├── jenkins/
│   ├── Jenkinsfile            # Pipeline definition
│   ├── create-jenkins-pipeline.xml
│   └── jenkins-setup.groovy
├── ansible/
│   ├── deploy-k8s.yml         # Ansible playbook for k8s deployment
│   └── deploy-docker.yml      # Ansible playbook for Docker deployment
├── k8s/                       # Kubernetes manifests
├── monitoring/                # Monitoring configuration
│   ├── prometheus.yml
│   ├── grafana-dashboard.json
│   └── docker-compose-monitoring.yml
├── aws/                       # AWS infrastructure templates
├── scripts/                   # Automation scripts
├── docs/                      # Documentation
└── inventory/                 # Ansible inventory
```

## Prerequisites
- AWS account with permissions to launch EC2 instances
- Docker installed (on your local machine or build server)
- kubectl installed (for k3s/k8s management)
- **Ansible installed** (locally or on Jenkins server) for deployment automation
- (Optional) Jenkins server (can be set up via script)
- (Optional) Monitoring EC2 instance for Prometheus/Grafana

## Step-by-Step Setup

### 1. **Clone the repository:**
```sh
git clone <your-repo-url>
cd abc-retail-devops
```

### 2. **Launch EC2 Instances:**
- Launch three EC2 instances (app/k3s, Jenkins, monitoring) using AWS Console or CloudFormation/Ansible scripts provided.
- Note their public IPs.

### 3. **Set up Kubernetes (k3s) and Deploy the App:**
```sh
chmod +x scripts/setup-all.sh
./scripts/setup-all.sh
```
- This builds and pushes the Docker image, and deploys the app to your k3s cluster using manifests in `k8s/`.
- **The Jenkins pipeline will use Ansible to automate deployment to Kubernetes.**
- Ansible playbooks are provided for both infrastructure setup (AWS) and application deployment (k8s).

### 4. **Set up Monitoring (Prometheus & Grafana):**
```sh
chmod +x scripts/setup-monitoring.sh
./scripts/setup-monitoring.sh <monitoring-server-ip> <ssh-key-path>
```
- This will install and configure Prometheus and Grafana on your monitoring EC2 instance.

### 5. **Set up Jenkins Pipeline:**
```sh
chmod +x scripts/setup-jenkins-pipeline.sh
./scripts/setup-jenkins-pipeline.sh
```
- This will configure Jenkins with the pipeline and required credentials.

## Using Jenkins UI for CI/CD
1. **Access Jenkins:**
   - URL: `http://<jenkins-ec2-public-ip>:8080`
   - Login: `admin/admin123` (unless changed)
2. **Trigger a Build:**
   - Click on your pipeline job (e.g., `abc-retail-pipeline-fixed`)
   - Click **Build Now**
3. **Monitor the Pipeline:**
   - Click on the build number to see progress
   - View **Console Output** for logs
4. **Automated Flow:**
   - Jenkins will checkout code, build/test with Maven, build/push Docker image, and **run an Ansible playbook (`ansible/deploy-k8s.yml`) to deploy to k8s** and run health checks automatically.

## Accessing Your Services
- **Application:**
  - URL: `http://<k3s-ec2-public-ip>:<NodePort>`
  - Find NodePort with:
    ```sh
    kubectl get service abc-retail-service -n abc-retail
    ```
- **Jenkins:**
  - URL: `http://<jenkins-ec2-public-ip>:8080`
- **Grafana:**
  - URL: `http://<monitoring-ec2-public-ip>:3000` (login: admin/admin123)
- **Prometheus:**
  - URL: `http://<monitoring-ec2-public-ip>:9090`

## Monitoring
- Grafana dashboard is pre-configured for app and system metrics.
- Prometheus scrapes your app and node-exporter by default.
- To add more targets, edit `monitoring/prometheus.yml` and restart the stack.

## Advanced Automation
- See `ansible/deploy-k8s.yml` for the Ansible playbook used in the pipeline.
- See `aws/aws-eks-setup.yml`, `aws/aws-free-tier-setup.yml`, etc., for infrastructure automation with Ansible.

## Clean Up
To remove all resources:
```sh
kubectl delete -f k8s/
```

## Notes
- Do **not** commit secrets or key files to the repo.
- For any issues, see the comments in the scripts or open an issue.
- For advanced AWS automation, see the provided CloudFormation/Ansible YAMLs.

---

**This README now provides a full, step-by-step guide for new users to set up, automate (with Ansible), and access all parts of the project!**
