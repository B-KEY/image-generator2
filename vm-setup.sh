#!/bin/bash

# Complete setup script for Google Cloud VM
# Run this AFTER uploading your files to the VM

echo "🔧 Setting up Image Generator on Google Cloud VM..."

# Update system
echo "📦 Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker if not already installed
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "✅ Docker installed! Please logout and login again, then run this script again."
    exit 0
fi

# Check if project files exist
if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile not found! Please upload your project files first."
    echo "Run this from your local machine:"
    echo "gcloud compute scp --recurse /workspaces/image-generator2 $(hostname):~/ --zone=YOUR_ZONE"
    exit 1
fi

# Build the Docker image
echo "🏗️  Building Docker image with font support..."
sudo docker build -t image-generator .

# Stop any existing container
echo "🛑 Stopping any existing containers..."
sudo docker stop image-generator 2>/dev/null || true
sudo docker rm image-generator 2>/dev/null || true

# Run the container
echo "🚀 Starting image generator container..."
sudo docker run -d \
    --name image-generator \
    -p 9000:9000 \
    --restart unless-stopped \
    image-generator

# Check if container is running
sleep 5
if sudo docker ps | grep -q image-generator; then
    echo "✅ Container is running successfully!"
    
    # Get external IP
    EXTERNAL_IP=$(curl -s ifconfig.me)
    echo ""
    echo "🌐 Your image generator is accessible at:"
    echo "   External: http://$EXTERNAL_IP:9000"
    echo "   Internal: http://localhost:9000"
    echo ""
    echo "🔧 Management commands:"
    echo "   View logs:     sudo docker logs image-generator"
    echo "   Stop:          sudo docker stop image-generator"
    echo "   Start:         sudo docker start image-generator"
    echo "   Restart:       sudo docker restart image-generator"
    echo "   Remove:        sudo docker rm -f image-generator"
    echo ""
    echo "🎯 Test it:"
    echo "   curl http://localhost:9000"
else
    echo "❌ Container failed to start. Check logs:"
    sudo docker logs image-generator
fi
