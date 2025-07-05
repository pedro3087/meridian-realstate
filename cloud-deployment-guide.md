# Google Cloud Platform Deployment Guide

## Step-by-Step Guide to Deploy Your Facebook Automation Tool to Google Cloud

### Prerequisites
1. **Google Cloud Account**: Sign up at [cloud.google.com](https://cloud.google.com)
2. **Google Cloud CLI**: Install from [cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
3. **Docker**: Install from [docker.com](https://docker.com)

### Step 1: Set Up Google Cloud Project

```bash
# Initialize Google Cloud CLI
gcloud init

# Create a new project (or use existing)
gcloud projects create meridian-automation-tool --name="Meridian Automation Tool"

# Set the project as active
gcloud config set project meridian-automation-tool

# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### Step 2: Configure Docker for Google Cloud

```bash
# Configure Docker to use Google Cloud credentials
gcloud auth configure-docker

# Set the project ID for Docker
export PROJECT_ID=$(gcloud config get-value project)
```

### Step 3: Build and Push Docker Image

```bash
# Build the Docker image
docker build -t gcr.io/$PROJECT_ID/facebook-automation-tool .

# Push the image to Google Container Registry
docker push gcr.io/$PROJECT_ID/facebook-automation-tool
```

### Step 4: Deploy to Cloud Run (Recommended)

```bash
# Deploy to Cloud Run
gcloud run deploy facebook-automation-tool \
  --image gcr.io/$PROJECT_ID/facebook-automation-tool \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 80
```

### Step 5: Alternative - Deploy to Google Kubernetes Engine (GKE)

If you prefer Kubernetes for more control:

```bash
# Create a GKE cluster
gcloud container clusters create automation-cluster \
  --zone us-central1-a \
  --num-nodes 1 \
  --machine-type e2-small

# Get credentials for the cluster
gcloud container clusters get-credentials automation-cluster --zone us-central1-a

# Create deployment YAML
cat << EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: facebook-automation-tool
spec:
  replicas: 2
  selector:
    matchLabels:
      app: facebook-automation-tool
  template:
    metadata:
      labels:
        app: facebook-automation-tool
    spec:
      containers:
      - name: facebook-automation-tool
        image: gcr.io/$PROJECT_ID/facebook-automation-tool
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: facebook-automation-tool-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: facebook-automation-tool
EOF

# Apply the deployment
kubectl apply -f deployment.yaml
```

### Step 6: Set Up Custom Domain (Optional)

```bash
# Map custom domain to Cloud Run service
gcloud run domain-mappings create \
  --service facebook-automation-tool \
  --domain your-domain.com \
  --region us-central1
```

### Step 7: Set Up Monitoring and Logging

```bash
# Enable Cloud Monitoring
gcloud services enable monitoring.googleapis.com

# Enable Cloud Logging
gcloud services enable logging.googleapis.com
```

### Step 8: Cost Optimization

```bash
# For Cloud Run - Set minimum instances to 0 for cost savings
gcloud run services update facebook-automation-tool \
  --min-instances 0 \
  --max-instances 10 \
  --region us-central1

# For GKE - Enable node auto-scaling
gcloud container clusters update automation-cluster \
  --enable-autoscaling \
  --min-nodes 0 \
  --max-nodes 3 \
  --zone us-central1-a
```

### Step 9: Continuous Deployment (Optional)

Create a Cloud Build trigger for automatic deployments:

```bash
# Create cloudbuild.yaml
cat << EOF > cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/facebook-automation-tool', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/facebook-automation-tool']
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'facebook-automation-tool'
      - '--image'
      - 'gcr.io/$PROJECT_ID/facebook-automation-tool'
      - '--region'
      - 'us-central1'
      - '--platform'
      - 'managed'
      - '--allow-unauthenticated'
EOF
```

### Step 10: Environment Variables and Secrets (If Needed)

```bash
# Set environment variables for Cloud Run
gcloud run services update facebook-automation-tool \
  --set-env-vars "ENVIRONMENT=production" \
  --region us-central1

# Or use Secret Manager for sensitive data
echo -n "your-secret-value" | gcloud secrets create my-secret --data-file=-
gcloud run services update facebook-automation-tool \
  --set-secrets "SECRET_KEY=my-secret:latest" \
  --region us-central1
```

### Step 11: SSL Certificate and Security

```bash
# Cloud Run automatically provides SSL certificates
# For custom domains, SSL is handled automatically

# Set up IAM policies for security
gcloud run services add-iam-policy-binding facebook-automation-tool \
  --member="serviceAccount:your-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.invoker" \
  --region us-central1
```

### Step 12: Backup and Disaster Recovery

```bash
# Enable Cloud Storage for backups
gsutil mb gs://$PROJECT_ID-backups

# Create a backup script
cat << EOF > backup.sh
#!/bin/bash
DATE=\$(date +%Y%m%d_%H%M%S)
gsutil cp guide_to_facebook_comment_automation.html gs://$PROJECT_ID-backups/backup_\$DATE.html
EOF

chmod +x backup.sh
```

### Step 13: Performance Optimization

```bash
# Enable CDN for static assets
gcloud compute url-maps create facebook-automation-cdn \
  --default-service facebook-automation-tool-service

# Set up Cloud CDN
gcloud compute backend-buckets create facebook-automation-backend \
  --gcs-bucket-name=$PROJECT_ID-backups
```

### Step 14: Monitoring and Alerts

```bash
# Create uptime check
gcloud monitoring uptime-checks create http facebook-automation-uptime \
  --uri="https://your-service-url.run.app" \
  --display-name="Facebook Automation Tool Uptime"

# Create alerting policy
gcloud alpha monitoring policies create \
  --policy-from-file=alert-policy.yaml
```

### Step 15: Scaling and Load Balancing

```bash
# For Cloud Run - Auto-scaling is enabled by default
# For GKE - Set up horizontal pod autoscaling

kubectl autoscale deployment facebook-automation-tool \
  --cpu-percent=70 \
  --min=1 \
  --max=10
```

## Cost Estimation

### Cloud Run (Recommended for this use case)
- **Free Tier**: 2 million requests/month, 360,000 vCPU-seconds, 180,000 GiB-seconds
- **Paid**: ~$0.40 per million requests + compute time
- **Estimated Monthly Cost**: $5-15 for typical usage

### GKE
- **Free Tier**: None
- **Paid**: ~$73/month for 1 node cluster
- **Estimated Monthly Cost**: $73-150

## Benefits of Cloud Deployment

1. **No Local Resource Consumption**: Runs entirely in the cloud
2. **Automatic Scaling**: Handles traffic spikes automatically
3. **High Availability**: 99.9% uptime SLA
4. **Global CDN**: Fast loading worldwide
5. **Automatic SSL**: HTTPS enabled by default
6. **Monitoring**: Built-in logging and monitoring
7. **Cost Effective**: Pay only for what you use

## Maintenance Commands

```bash
# Update the application
docker build -t gcr.io/$PROJECT_ID/facebook-automation-tool .
docker push gcr.io/$PROJECT_ID/facebook-automation-tool
gcloud run deploy facebook-automation-tool --image gcr.io/$PROJECT_ID/facebook-automation-tool

# View logs
gcloud run logs read facebook-automation-tool --region us-central1

# Monitor costs
gcloud billing budgets create --billing-account=YOUR_BILLING_ACCOUNT \
  --display-name="Facebook Automation Budget" \
  --budget-amount=50USD \
  --threshold-rule=percent=0.5 \
  --threshold-rule=percent=0.9
```

## Troubleshooting

### Common Issues:

1. **Permission Denied**: Run `gcloud auth login`
2. **Image Not Found**: Ensure you've pushed the image to GCR
3. **Service Unavailable**: Check Cloud Run quotas and limits
4. **High Costs**: Review and adjust scaling parameters

### Useful Commands:

```bash
# Check service status
gcloud run services describe facebook-automation-tool --region us-central1

# View recent deployments
gcloud run revisions list --service facebook-automation-tool --region us-central1

# Check billing
gcloud billing accounts list
```

This deployment will give you a production-ready, scalable web application that runs entirely in the cloud without consuming any local resources! 