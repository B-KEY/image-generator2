# Docker Deployment for Google Cloud - Font-Fixed Version

This project can be deployed to Google Cloud using Docker in several ways. **The font rendering issue has been fixed** - text will now display properly instead of small rectangles.

## Font Fix Details

The Docker image now includes:
- Multiple font families: DejaVu Sans, Liberation Sans, Noto fonts
- Font configuration and caching
- Proper SVG text rendering support
- Support for international characters (CJK, Emoji)

## Prerequisites

1. **Google Cloud SDK**: Install and configure gcloud CLI
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Docker**: Ensure Docker is installed and running

3. **Enable APIs**: Enable required Google Cloud APIs
   ```bash
   gcloud services enable run.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   ```

## Deployment Options

### Option 1: Google Cloud Run (Recommended for serverless)

Cloud Run is perfect for this application as it automatically scales based on traffic.

1. **Update the deployment script**:
   - Edit `deploy-to-cloudrun.sh`
   - Replace `your-project-id` with your actual Google Cloud project ID

2. **Deploy**:
   ```bash
   ./deploy-to-cloudrun.sh
   ```

### Option 2: Google Kubernetes Engine (GKE)

For more control and complex workloads:

1. **Create a GKE cluster**:
   ```bash
   gcloud container clusters create image-generator-cluster \
     --zone us-central1-a \
     --num-nodes 3
   ```

2. **Build and push the image**:
   ```bash
   docker build -t gcr.io/YOUR_PROJECT_ID/image-generator .
   docker push gcr.io/YOUR_PROJECT_ID/image-generator
   ```

3. **Update k8s-deployment.yaml**:
   - Replace `YOUR_PROJECT_ID` with your actual project ID

4. **Deploy to Kubernetes**:
   ```bash
   kubectl apply -f k8s-deployment.yaml
   ```

### Option 3: Google Compute Engine with Docker

For traditional VM deployment:

1. **Create a VM instance**:
   ```bash
   gcloud compute instances create image-generator-vm \
     --image-family cos-stable \
     --image-project cos-cloud \
     --machine-type e2-medium \
     --zone us-central1-a
   ```

2. **SSH into the VM and run**:
   ```bash
   docker run -p 80:9000 gcr.io/YOUR_PROJECT_ID/image-generator
   ```

## Local Testing

Before deploying, test locally:

```bash
# Build the image
docker build -t image-generator .

# Run locally
docker run -p 9000:9000 image-generator

# Or use docker-compose
docker-compose up
```

## Environment Variables

The application uses these environment variables:
- `PORT`: Server port (default: 9000)
- `NODE_ENV`: Environment mode (production/development)

## Health Checks

The deployment includes health checks that monitor:
- HTTP GET requests to `/`
- Container resource usage
- Application responsiveness

## Cost Considerations

- **Cloud Run**: Pay per request, ideal for variable traffic
- **GKE**: Fixed cost for cluster + node usage
- **Compute Engine**: Fixed VM costs

Choose based on your traffic patterns and requirements.

## Troubleshooting

1. **Build failures**: Check Dockerfile and dependencies
2. **Memory issues**: Increase memory limits in deployment configs
3. **Image processing**: Sharp library requires sufficient CPU/memory for image operations

## Security Notes

- The container runs as a non-root user
- Health checks ensure service availability
- LoadBalancer service type for external access in GKE
