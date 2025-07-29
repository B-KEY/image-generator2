# Image Generator with Text Overlay

A Node.js web application that generates images with custom text overlays using Sharp image processing library. Features a clean web interface and REST API for automated image generation.

## 🌟 Features

- **Web Interface**: Easy-to-use form for image generation
- **Custom Text**: Add any text with multiple formatting options
- **Font Rendering**: Fixed font support for Docker containers (no more rectangles!)
- **Flexible Positioning**: Top, middle, or bottom text placement
- **Color Customization**: Full color picker for text colors
- **Multiple Font Sizes**: 5 different size options (29px to 80px)
- **Text Alignment**: Left, center, or right alignment
- **REST API**: Programmatic access for automation
- **Docker Ready**: Containerized with proper font support
- **Cloud Deployable**: Ready for Google Cloud, Vercel, or local deployment

## 🚀 Quick Start

### Local Development
```bash
npm install
npm start
# Visit http://localhost:9000
```

### Docker (Recommended)
```bash
# Build and run with font support
docker build -t image-generator .
docker run -p 9000:9000 image-generator

# Or use the automated script
./deploy-local-free.sh
```

## 📋 API Usage

### Generate Image
```bash
POST /generate
Content-Type: application/json

{
  "text": "Your text here",
  "fontSize": 48,
  "color": "#FFFFFF",
  "position": "middle",
  "align": "center"
}
```

### Example with curl:
```bash
curl -X POST http://localhost:9000/generate \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello World!", "fontSize": 64, "color": "#FF0000"}' \
  --output generated-image.png
```

## 🎨 Customization Options

| Parameter | Options | Default |
|-----------|---------|---------|
| `fontSize` | 29, 36, 48, 64, 80 | 48 |
| `color` | Any hex color | #FFFFFF |
| `position` | top, middle, bottom | middle |
| `align` | left, center, right | center |

## 🐳 Deployment Options

### Google Cloud Run (Free Tier)
```bash
# Edit deploy-to-cloudrun.sh with your project ID
./deploy-to-cloudrun.sh
```

### Google Cloud VM
```bash
# Upload and deploy to VM
./deploy-to-vm.sh VM_NAME ZONE
```

### Local with Docker
```bash
./deploy-local-free.sh
```

## 🔧 Technical Details

- **Backend**: Node.js with Express
- **Image Processing**: Sharp library
- **Font Support**: DejaVu Sans, Liberation Sans, Noto fonts
- **Container**: Alpine Linux with font packages
- **Port**: 9000 (configurable via PORT env var)

## 🛠️ Font Fix

This version includes a complete fix for the font rendering issue in Docker containers:
- ✅ Proper font packages installed
- ✅ Font configuration and caching
- ✅ SVG text rendering with fallback fonts
- ✅ No more small rectangles instead of text!

## 📁 Project Structure

```
image-generator2/
├── server.js              # Main application server
├── package.json           # Node.js dependencies
├── Dockerfile             # Docker configuration with fonts
├── public/                # Frontend files
│   ├── index.html         # Web interface
│   ├── script.js          # Frontend JavaScript
│   ├── styles.css         # Styling
│   └── template.png       # Base template image
├── deploy-to-cloudrun.sh  # Google Cloud Run deployment
├── deploy-local-free.sh   # Local Docker deployment
├── deploy-to-vm.sh        # Google Cloud VM deployment
└── verify-deployment.sh   # Test deployment script
```

## 🤝 Integration

Perfect for integration with:
- **n8n workflows** for automated image generation
- **APIs and webhooks** for dynamic content
- **Batch processing** of multiple images
- **Social media automation**

## 📝 License

MIT License - feel free to use and modify!

## 🐛 Troubleshooting

**Font rendering issues?**
- Use the updated Dockerfile with font packages
- Ensure you're using the DejaVu Sans font family

**Container not starting?**
- Check logs: `docker logs image-generator`
- Verify port 9000 is available
- Run the verification script: `./verify-deployment.sh`

## 🎯 Coming Soon

- [ ] Multiple template support
- [ ] Batch image generation
- [ ] More font options
- [ ] Image filters and effects
