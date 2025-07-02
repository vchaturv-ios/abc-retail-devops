# ABC Retail DevOps Project

## Overview
This project demonstrates a complete DevOps pipeline for a Java application using:
- **GitHub** for source code management
- **Jenkins** for CI/CD
- **Docker** for containerization
- **Kubernetes (k3s on AWS EC2)** for deployment
- **Prometheus & Grafana** for monitoring

## Project Structure
```
abc-retail-devops/
├── src/                   # Java source code
├── k8s/                   # Kubernetes manifests (deployment.yaml, service.yaml, etc.)
├── Dockerfile             # For building the app image
├── Jenkinsfile            # CI/CD pipeline (for Jenkins)
├── setup-all.sh           # Single script to run the full flow
├── README.md              # This file
├── .gitignore
```

## Prerequisites
- Docker installed and running
- kubectl installed and configured to point to your k3s cluster (on AWS EC2)
- (Optional) k3s installed on your AWS EC2 instance
- (Optional) Jenkins server for CI/CD

## Quick Start
1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd abc-retail-devops
   ```
2. **Run the setup script:**
   ```sh
   chmod +x setup-all.sh
   ./setup-all.sh
   ```
   This will:
   - Build and push the Docker image
   - Deploy the app to your Kubernetes cluster using manifests in `k8s/`

3. **Access your app:**
   - Find the NodePort or LoadBalancer port from your service manifest
   - Visit `http://<EC2_PUBLIC_IP>:<NodePort>` in your browser

## Jenkins CI/CD
- Use the provided `Jenkinsfile` for automated build, push, and deploy.
- Store your kubeconfig as a Jenkins secret file credential for secure deployments.

## Monitoring
- See `monitoring/` or ask for Prometheus/Grafana setup instructions.

## Clean Up
- To remove all resources:
  ```sh
  kubectl delete -f k8s/
  ```

## Notes
- Do **not** commit secrets or key files to the repo.
- For any issues, see the comments in `setup-all.sh` or open an issue.

# Monitoring Setup

To set up Prometheus and Grafana for monitoring:

1. **SSH into your monitoring EC2 instance:**
   ```sh
   ssh -i <your-key>.pem ec2-user@<monitoring-instance-public-ip>
   ```
2. **Clone this repository (if not already):**
   ```sh
   git clone <your-repo-url>
   cd abc-retail-devops
   ```
3. **Run the monitoring setup script:**
   ```sh
   chmod +x setup-monitoring.sh
   ./setup-monitoring.sh
   ```
4. **Access Prometheus and Grafana:**
   - Prometheus: `http://<monitoring-instance-public-ip>:9090`
   - Grafana: `http://<monitoring-instance-public-ip>:3000` (login: admin/admin123)

Prometheus is pre-configured to scrape your k3s/app server. You can add more scrape targets in `monitoring/prometheus.yml` as needed.
