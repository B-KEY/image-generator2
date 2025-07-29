#!/bin/bash

# Free Tier Optimized Deployment for Google Cloud Run
# This script is specifically designed for Google Cloud free tier usage

echo "🆓 Starting FREE TIER deployment to Google Cloud Run..."
echo "💡 This deployment is optimized to stay within free tier limits"

# Check if user has set their project ID
if [ "$1" = "" ]; then
    echo "❌ Please provide your Google Cloud Project ID"
    echo "Usage: ./deploy-free-tier.sh YOUR_PROJECT_ID"
    exit 1
fi

PROJECT_ID="$1"
SERVICE_NAME="image-generator"
REGION="us-central1"  # Free tier eligible region
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "📋 Deployment Details:"
echo "   Project ID: $PROJECT_ID"
echo "   Service: $SERVICE_NAME"
echo "   Region: $REGION (Free tier eligible)"
echo "   Memory: 512Mi (Free tier optimized)"
echo ""

# Set the project
echo "🔧 Setting up Google Cloud project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔌 Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build the Docker image
echo "🐳 Building Docker image with font support..."
docker build -t $IMAGE_NAME .

# Configure Docker to use gcloud credentials
echo "🔐 Configuring Docker authentication..."
gcloud auth configure-docker

# Push the image to Container Registry
echo "⬆️ Pushing image to Google Container Registry..."
docker push $IMAGE_NAME

# Deploy to Cloud Run with free-tier settings
echo "🚀 Deploying to Cloud Run (FREE TIER OPTIMIZED)..."
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 9000 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 2 \
  --concurrency 10 \
  --timeout 300 \
  --set-env-vars NODE_ENV=production

echo ""
echo "✅ FREE TIER deployment completed!"
echo "💰 Your app will scale to ZERO when not in use = $0 cost"
echo "🎯 Free tier includes: 2M requests/month + 400K GB-seconds"
echo ""
echo "🌐 Your service URL:"
gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)'
echo ""
echo "📊 Monitor your usage at: https://console.cloud.google.com/run"
