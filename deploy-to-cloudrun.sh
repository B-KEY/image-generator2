#!/bin/bash

# Build and Deploy Script for Google Cloud Run

# Set your Google Cloud project variables
PROJECT_ID="your-project-id"
SERVICE_NAME="image-generator"
REGION="us-central1"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "🚀 Starting deployment to Google Cloud Run..."

# Step 1: Build the Docker image with font support
echo "📦 Building Docker image with font support..."
docker build -t $IMAGE_NAME .

# Step 2: Push the image to Google Container Registry
echo "⬆️ Pushing image to Container Registry..."
docker push $IMAGE_NAME

# Step 3: Deploy to Cloud Run with free-tier optimized settings
echo "🌐 Deploying to Cloud Run (Free Tier Optimized)..."
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 9000 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 3 \
  --concurrency 10 \
  --timeout 300 \
  --set-env-vars NODE_ENV=production

echo "✅ Deployment completed!"
echo "Your service should be available at:"
gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)'
