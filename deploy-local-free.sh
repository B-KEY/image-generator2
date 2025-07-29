#!/bin/bash

# Local Free Deployment Script
# Run your image generator completely free on your local Docker

echo "🆓 Starting LOCAL deployment (100% FREE)..."
echo "🐳 This will run alongside your existing n8n setup"

# Build the image with font support
echo "📦 Building image generator with font support..."
docker build -t image-generator-local .

# Option 1: Simple standalone run
echo ""
echo "🚀 Option 1: Standalone (Recommended)"
echo "Run alongside your n8n:"
echo ""
echo "docker run -d --name image-generator \\"
echo "  -p 9000:9000 \\"
echo "  --restart unless-stopped \\"
echo "  image-generator-local"
echo ""

# Option 2: Docker Compose
echo "🚀 Option 2: Docker Compose (Advanced)"
echo "Integrate with existing docker-compose:"
echo ""
echo "docker-compose -f docker-compose-local.yml up -d"
echo ""

# Run the simple version
echo "✨ Starting in standalone mode..."
docker run -d --name image-generator \
  -p 9000:9000 \
  --restart unless-stopped \
  image-generator-local

echo ""
echo "✅ SUCCESS! Your image generator is running!"
echo "🌐 Access your web app at: http://localhost:9000"
echo "🛠️  n8n (if running): http://localhost:5678 (or your n8n port)"
echo "💰 Total cost: $0.00 (completely free!)"
echo ""
echo "🔧 Management commands:"
echo "  Stop:    docker stop image-generator"
echo "  Start:   docker start image-generator"
echo "  Logs:    docker logs image-generator"
echo "  Remove:  docker rm -f image-generator"
echo ""
echo "🎯 Integration with n8n:"
echo "  Your n8n workflows can call: http://localhost:9000/generate"
echo "  Perfect for automated image generation!"
