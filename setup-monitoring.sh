#!/bin/bash
set -e

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <monitoring-server-ip> <ssh-key-path> [ec2-user]"
  exit 1
fi

MON_IP="$1"
KEY_PATH="$2"
USER="${3:-ec2-user}"

echo "🔧 Setting up monitoring for ABC Retail application..."

# Get the application server IP
APP_SERVER_IP="107.21.169.207"
JENKINS_SERVER_IP="34.228.11.74"

echo "📊 Application Server: $APP_SERVER_IP"
echo "🔧 Jenkins Server: $JENKINS_SERVER_IP"
echo "📈 Monitoring Server: $MON_IP"

# Copy monitoring files to remote server
scp -i "$KEY_PATH" -r monitoring "$USER@$MON_IP:/home/$USER/"

# Run setup commands remotely
ssh -i "$KEY_PATH" "$USER@$MON_IP" 'bash -s' <<'ENDSSH'
set -e
cd /home/$USER/monitoring

# Install Docker
if ! command -v docker >/dev/null 2>&1; then
  sudo yum update -y
  sudo yum install -y docker
  sudo service docker start
  sudo usermod -aG docker $USER
fi

echo "[INFO] Docker version: $(docker --version)"

# Install Docker Compose
if ! command -v docker-compose >/dev/null 2>&1; then
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

echo "[INFO] Docker Compose version: $(docker-compose --version)"

# Stop and remove old Prometheus and Grafana containers if running
sudo docker ps -q --filter "publish=9090" | xargs -r sudo docker stop | xargs -r sudo docker rm
sudo docker ps -q --filter "publish=3000" | xargs -r sudo docker stop | xargs -r sudo docker rm

# Start Prometheus & Grafana
sudo docker-compose -f docker-compose-monitoring.yml up -d

# Wait for Grafana to be up
for i in {1..30}; do
  if curl -s http://localhost:3000/api/health | grep -q '"database": "ok"'; then
    echo "[INFO] Grafana is up!"
    break
  fi
  echo "[INFO] Waiting for Grafana to start... ($i/30)"
  sleep 5
done

# Import dashboard and set as home
if [ -f grafana-dashboard.json ]; then
  echo "[INFO] Importing Grafana dashboard..."
  IMPORT_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d @grafana-dashboard.json \
    http://admin:admin123@localhost:3000/api/dashboards/db || true)
  echo "$IMPORT_RESPONSE"
  DASHBOARD_UID=$(echo "$IMPORT_RESPONSE" | grep -o '"uid":"[^"]*"' | head -1 | cut -d'"' -f4)
  if [ -n "$DASHBOARD_UID" ]; then
    echo "[INFO] Setting dashboard $DASHBOARD_UID as home dashboard..."
    # Get dashboard ID
    DASHBOARD_ID=$(curl -s http://admin:admin123@localhost:3000/api/dashboards/uid/$DASHBOARD_UID | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    if [ -n "$DASHBOARD_ID" ]; then
      curl -s -X PUT -H "Content-Type: application/json" \
        -d "{\"homeDashboardId\":$DASHBOARD_ID}" \
        http://admin:admin123@localhost:3000/api/org/preferences
      echo "[INFO] Home dashboard set!"
    else
      echo "[WARN] Could not determine dashboard ID for home dashboard."
    fi
  else
    echo "[WARN] Could not determine dashboard UID for home dashboard."
  fi
else
  echo "[WARN] grafana-dashboard.json not found, skipping dashboard import."
fi

echo "[DONE] Prometheus: http://$MON_IP:9090"
echo "[DONE] Grafana: http://$MON_IP:3000 (admin/admin123)"

# Create Prometheus configuration
cat > prometheus.yml << EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'abc-retail-app'
    static_configs:
      - targets: ['$APP_SERVER_IP:8080']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 10s

  - job_name: 'jenkins'
    static_configs:
      - targets: ['$JENKINS_SERVER_IP:8080']
    metrics_path: '/prometheus'
    scrape_interval: 30s
EOF

echo "✅ Prometheus configuration created: prometheus.yml"

# Copy configuration to monitoring server
echo "📤 Copying configuration to monitoring server..."
scp -i "$KEY_PATH" prometheus.yml "$USER@$MON_IP:/tmp/"

# Update Prometheus configuration on the server
ssh -i "$KEY_PATH" "$USER@$MON_IP" << 'EOF'
sudo docker cp /tmp/prometheus.yml prometheus:/etc/prometheus/prometheus.yml
sudo docker restart prometheus
EOF

echo "✅ Prometheus configuration updated and restarted"

# Create a simple Grafana dashboard configuration
cat > grafana-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "ABC Retail Application Monitoring",
    "tags": ["abc-retail", "monitoring"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Application Health",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"abc-retail-app\"}",
            "legendFormat": "Application Status"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "green", "value": 1}
              ]
            }
          }
        }
      },
      {
        "id": 2,
        "title": "System CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ]
      },
      {
        "id": 3,
        "title": "System Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "Memory Usage %"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "10s"
  }
}
EOF

echo "✅ Grafana dashboard configuration created: grafana-dashboard.json"

echo ""
echo "🎯 Next Steps:"
echo "1. In Grafana (http://$MON_IP:3000):"
echo "   - Add Prometheus data source: http://localhost:9090"
echo "   - Import dashboard from: grafana-dashboard.json"
echo ""
echo "2. Access your services:"
echo "   - Application: http://$APP_SERVER_IP:8080"
echo "   - Jenkins: http://$JENKINS_SERVER_IP:8080"
echo "   - Grafana: http://$MON_IP:3000"
echo "   - Prometheus: http://$MON_IP:9090"
echo ""
echo "🚀 Your complete DevOps monitoring stack is ready!"
ENDSSH

echo "✅ Monitoring setup completed successfully!" 