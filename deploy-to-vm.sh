#!/bin/bash

# Deploy to Google Cloud VM via SSH
# This script helps you deploy your image generator on a Google Cloud VM

echo "🌐 Deploying to Google Cloud VM..."
echo "📋 This will install Docker and run your image generator on a VM"

# Check if VM details are provided
if [ "$1" = "" ] || [ "$2" = "" ]; then
    echo "❌ Usage: ./deploy-to-vm.sh VM_NAME ZONE"
    echo "Example: ./deploy-to-vm.sh my-vm us-central1-a"
    exit 1
fi

VM_NAME="$1"
ZONE="$2"

echo "🖥️  VM Name: $VM_NAME"
echo "🌍 Zone: $ZONE"

# Create VM if it doesn't exist (free tier eligible)
echo "🚀 Creating VM (if not exists)..."
gcloud compute instances create $VM_NAME \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-standard \
    --tags=http-server,https-server

# Enable firewall for port 9000
echo "🔥 Setting up firewall..."
gcloud compute firewall-rules create allow-image-generator \
    --allow tcp:9000 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow image generator on port 9000" 2>/dev/null || echo "Firewall rule already exists"

# Copy files to VM
echo "📤 Copying files to VM..."
gcloud compute scp --zone=$ZONE --recurse . $VM_NAME:~/image-generator/

# Connect and setup
echo "🔧 Setting up on VM..."
gcloud compute ssh --zone=$ZONE $VM_NAME --command "
    # Update system
    sudo apt-get update -y
    
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker \$USER
    
    # Build and run the image generator
    cd ~/image-generator
    sudo docker build -t image-generator .
    sudo docker run -d --name image-generator -p 9000:9000 --restart unless-stopped image-generator
    
    echo '✅ Image generator is running!'
    echo '🌐 Access at: http://\$(curl -s ifconfig.me):9000'
"

# Get external IP
EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo "✅ Deployment completed!"
echo "🌐 Your image generator is available at: http://$EXTERNAL_IP:9000"
echo "🖥️  SSH to VM: gcloud compute ssh --zone=$ZONE $VM_NAME"
echo "💰 Cost: ~$5-7/month for e2-micro VM (or free tier if eligible)"
