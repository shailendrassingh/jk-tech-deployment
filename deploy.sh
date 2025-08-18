#!/bin/bash
set -e

AWS_EC2_IP="YOUR_AWS_EC2_IP"
PEM_PATH="~/.ssh/your-key.pem"
PROJECT_DIR="/home/ec2-user/app"

echo "Building Docker images..."
docker-compose build

echo "Saving images..."
docker save project-root_backend:latest | gzip > backend.tar.gz
docker save project-root_frontend:latest | gzip > frontend.tar.gz

echo "Uploading images to server..."
scp -i $PEM_PATH backend.tar.gz frontend.tar.gz ec2-user@$AWS_EC2_IP:$PROJECT_DIR
scp -i $PEM_PATH docker-compose.yml ec2-user@$AWS_EC2_IP:$PROJECT_DIR

echo "Deploying on server..."
ssh -i $PEM_PATH ec2-user@$AWS_EC2_IP << 'EOF'
  cd ~/app
  gunzip -f backend.tar.gz && docker load < backend.tar
  gunzip -f frontend.tar.gz && docker load < frontend.tar
  docker-compose up -d
EOF

echo "Deployment complete!"
