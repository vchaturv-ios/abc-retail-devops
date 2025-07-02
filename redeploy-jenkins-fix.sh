#!/bin/bash

echo "🚀 Redeploying Jenkins server with Docker permission fixes..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible &>/dev/null; then
    echo "❌ Ansible not found. Please install Ansible first."
    exit 1
fi

echo "📋 Running Ansible playbook to redeploy infrastructure..."
ansible-playbook aws-free-tier-setup.yml

if [ $? -eq 0 ]; then
    echo "✅ Infrastructure redeployed successfully!"
    echo ""
    echo "🔍 Getting instance information..."
    
    # Get Jenkins server IP
    JENKINS_IP=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=abc-retail-jenkins-free" "Name=instance-state-name,Values=running" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text 2>/dev/null)
    
    if [ "$JENKINS_IP" != "None" ] && [ "$JENKINS_IP" != "" ]; then
        echo "🎯 Jenkins Server IP: $JENKINS_IP"
        echo "🌐 Jenkins URL: http://$JENKINS_IP:8080"
        echo ""
        echo "⏳ Waiting for Jenkins to be ready..."
        echo "   (This may take 2-3 minutes)"
        
        # Wait for Jenkins to be ready
        for i in {1..30}; do
            if curl -s http://$JENKINS_IP:8080 &>/dev/null; then
                echo "✅ Jenkins is ready!"
                break
            fi
            echo "   Waiting... ($i/30)"
            sleep 10
        done
        
        echo ""
        echo "🔧 Next steps:"
        echo "1. Access Jenkins at: http://$JENKINS_IP:8080"
        echo "2. Get the initial admin password:"
        echo "   ssh -i abc-retail-free-key.pem ec2-user@$JENKINS_IP"
        echo "   sudo docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword"
        echo "3. Recreate your Jenkins pipeline job"
        echo "4. Run the pipeline - Docker builds should now work!"
        
    else
        echo "❌ Could not retrieve Jenkins IP. Check AWS console for instance details."
    fi
else
    echo "❌ Ansible playbook failed. Check the output above for errors."
    exit 1
fi 