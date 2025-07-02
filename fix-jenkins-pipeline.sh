#!/bin/bash

echo "🔧 Fixing Jenkins Pipeline Script"
echo "================================="
echo ""

echo "❌ Problem: Pipeline script contains invalid characters (# comments)"
echo "✅ Solution: Use the clean pipeline script without comments"
echo ""

echo "📋 Steps to Fix:"
echo "================"
echo ""
echo "1. Go to Jenkins: http://34.228.11.74:8080"
echo "2. Login with admin/admin123"
echo "3. Click on 'abc-retail-pipeline' job"
echo "4. Click 'Configure'"
echo "5. Scroll down to 'Pipeline' section"
echo "6. Replace the entire script with the content from 'clean-jenkins-pipeline.groovy'"
echo "7. Click 'Save'"
echo "8. Click 'Build Now'"
echo ""

echo "📄 Clean Pipeline Script:"
echo "========================="
echo ""
cat clean-jenkins-pipeline.groovy
echo ""

echo "🔑 Important Notes:"
echo "=================="
echo "1. Make sure Docker Hub credentials are set up with ID: 'dockerhub-creds'"
echo "2. Ensure all required plugins are installed"
echo "3. The script will build, test, deploy, and monitor your application"
echo ""

echo "✅ After fixing, your pipeline should run successfully!" 