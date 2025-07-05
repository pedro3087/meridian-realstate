#!/bin/bash

# Google Cloud Deployment Script for Facebook Automation Tool
# This script automates the deployment process to Google Cloud Platform

set -e  # Exit on any error

echo "🚀 Starting Google Cloud Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Get project configuration
setup_project() {
    print_status "Setting up Google Cloud project..."
    
    # Get current project
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
    
    if [ -z "$PROJECT_ID" ]; then
        print_warning "No project is set. Please run 'gcloud init' first."
        read -p "Enter your project ID: " PROJECT_ID
        gcloud config set project $PROJECT_ID
    fi
    
    print_success "Using project: $PROJECT_ID"
    
    # Enable required APIs
    print_status "Enabling required APIs..."
    gcloud services enable cloudbuild.googleapis.com --quiet
    gcloud services enable run.googleapis.com --quiet
    gcloud services enable containerregistry.googleapis.com --quiet
    
    print_success "APIs enabled successfully"
}

# Configure Docker for Google Cloud
configure_docker() {
    print_status "Configuring Docker for Google Cloud..."
    gcloud auth configure-docker --quiet
    print_success "Docker configured for Google Cloud"
}

# Build and push Docker image
build_and_push() {
    print_status "Building Docker image..."
    
    # Build the image
    docker build -t gcr.io/$PROJECT_ID/facebook-automation-tool .
    
    if [ $? -eq 0 ]; then
        print_success "Docker image built successfully"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
    
    print_status "Pushing image to Google Container Registry..."
    docker push gcr.io/$PROJECT_ID/facebook-automation-tool
    
    if [ $? -eq 0 ]; then
        print_success "Image pushed successfully"
    else
        print_error "Failed to push image"
        exit 1
    fi
}

# Deploy to Cloud Run
deploy_to_cloud_run() {
    print_status "Deploying to Cloud Run..."
    
    # Deploy the service
    gcloud run deploy facebook-automation-tool \
        --image gcr.io/$PROJECT_ID/facebook-automation-tool \
        --platform managed \
        --region us-central1 \
        --allow-unauthenticated \
        --port 80 \
        --memory 512Mi \
        --cpu 1 \
        --max-instances 10 \
        --min-instances 0
    
    if [ $? -eq 0 ]; then
        print_success "Deployed to Cloud Run successfully"
        
        # Get the service URL
        SERVICE_URL=$(gcloud run services describe facebook-automation-tool \
            --region us-central1 \
            --format="value(status.url)")
        
        print_success "Your application is available at: $SERVICE_URL"
    else
        print_error "Failed to deploy to Cloud Run"
        exit 1
    fi
}

# Set up monitoring
setup_monitoring() {
    print_status "Setting up monitoring..."
    
    # Enable monitoring and logging
    gcloud services enable monitoring.googleapis.com --quiet
    gcloud services enable logging.googleapis.com --quiet
    
    print_success "Monitoring and logging enabled"
}

# Main deployment function
main() {
    echo "=========================================="
    echo "Google Cloud Deployment Script"
    echo "=========================================="
    
    check_prerequisites
    setup_project
    configure_docker
    build_and_push
    deploy_to_cloud_run
    setup_monitoring
    
    echo "=========================================="
    print_success "Deployment completed successfully!"
    echo "=========================================="
    
    # Display next steps
    echo ""
    echo "Next steps:"
    echo "1. Visit your application URL to verify it's working"
    echo "2. Set up a custom domain if needed"
    echo "3. Configure monitoring alerts"
    echo "4. Set up billing alerts to monitor costs"
    echo ""
    echo "To update your application in the future, simply run this script again."
}

# Run the main function
main "$@" 