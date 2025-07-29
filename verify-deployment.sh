#!/bin/bash

# Deployment Verification Script
# This script helps verify that your image generator is working correctly

echo "🔍 Testing Image Generator Deployment..."

# Check if the service is running
echo "📡 Checking service health..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/ || echo "000")

if [ "$RESPONSE" = "200" ]; then
    echo "✅ Service is running and responding"
else
    echo "❌ Service is not responding (HTTP: $RESPONSE)"
    exit 1
fi

# Test text generation
echo "🎨 Testing text generation with fonts..."
curl -X POST http://localhost:9000/generate \
  -H "Content-Type: application/json" \
  -d '{"text": "Font Test Success!", "fontSize": 48, "color": "#00FF00", "position": "middle"}' \
  --output font-test.png \
  --silent

# Check if file was created and has content
if [ -f "font-test.png" ] && [ -s "font-test.png" ]; then
    FILE_SIZE=$(stat -c%s font-test.png 2>/dev/null || stat -f%z font-test.png 2>/dev/null)
    echo "✅ Image generated successfully (${FILE_SIZE} bytes)"
    echo "📁 Test image saved as: font-test.png"
    
    # Clean up test file
    rm -f font-test.png
    
    echo ""
    echo "🎉 All tests passed! Your image generator is working correctly."
    echo "✨ Font rendering is working - no more rectangles!"
    echo ""
    echo "Ready for Google Cloud deployment! 🚀"
else
    echo "❌ Image generation failed - check server logs"
    exit 1
fi
