# Google Cloud Deployment Script for Facebook Automation Tool (PowerShell)
# This script automates the deployment process to Google Cloud Platform

param(
    [string]$ProjectId = "",
    [string]$Region = "us-central1"
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Google Cloud Deployment..." -ForegroundColor Cyan

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if required tools are installed
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    # Check if gcloud is installed
    try {
        $null = Get-Command gcloud -ErrorAction Stop
    }
    catch {
        Write-Error "Google Cloud CLI is not installed. Please install it first."
        Write-Host "Download from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
        exit 1
    }
    
    # Check if docker is installed
    try {
        $null = Get-Command docker -ErrorAction Stop
    }
    catch {
        Write-Error "Docker is not installed. Please install Docker Desktop for Windows first."
        Write-Host "Download from: https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Yellow
        exit 1
    }
    
    # Check if Docker Desktop is running
    try {
        docker version | Out-Null
    }
    catch {
        Write-Error "Docker Desktop is not running. Please start Docker Desktop and try again."
        exit 1
    }
    
    Write-Success "All prerequisites are installed and running"
}

# Get project configuration
function Set-ProjectConfiguration {
    Write-Status "Setting up Google Cloud project..."
    
    # Get current project
    $currentProject = gcloud config get-value project 2>$null
    
    if ([string]::IsNullOrEmpty($currentProject)) {
        Write-Warning "No project is set. Please run 'gcloud init' first."
        if ([string]::IsNullOrEmpty($ProjectId)) {
            $ProjectId = Read-Host "Enter your project ID"
        }
        gcloud config set project $ProjectId
    }
    else {
        $ProjectId = $currentProject
    }
    
    Write-Success "Using project: $ProjectId"
    
    # Enable required APIs
    Write-Status "Enabling required APIs..."
    gcloud services enable cloudbuild.googleapis.com --quiet
    gcloud services enable run.googleapis.com --quiet
    gcloud services enable containerregistry.googleapis.com --quiet
    
    Write-Success "APIs enabled successfully"
}

# Configure Docker for Google Cloud
function Set-DockerConfiguration {
    Write-Status "Configuring Docker for Google Cloud..."
    gcloud auth configure-docker --quiet
    Write-Success "Docker configured for Google Cloud"
}

# Build and push Docker image
function Build-AndPush {
    Write-Status "Building Docker image..."
    
    # Build the image
    docker build -t "gcr.io/$ProjectId/facebook-automation-tool" .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker image built successfully"
    }
    else {
        Write-Error "Failed to build Docker image"
        exit 1
    }
    
    Write-Status "Pushing image to Google Container Registry..."
    docker push "gcr.io/$ProjectId/facebook-automation-tool"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Image pushed successfully"
    }
    else {
        Write-Error "Failed to push image"
        exit 1
    }
}

# Deploy to Cloud Run
function Deploy-ToCloudRun {
    Write-Status "Deploying to Cloud Run..."
    
    # Deploy the service
    gcloud run deploy facebook-automation-tool `
        --image "gcr.io/$ProjectId/facebook-automation-tool" `
        --platform managed `
        --region $Region `
        --allow-unauthenticated `
        --port 80 `
        --memory 512Mi `
        --cpu 1 `
        --max-instances 10 `
        --min-instances 0
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Deployed to Cloud Run successfully"
        
        # Get the service URL
        $serviceUrl = gcloud run services describe facebook-automation-tool `
            --region $Region `
            --format="value(status.url)"
        
        Write-Success "Your application is available at: $serviceUrl"
    }
    else {
        Write-Error "Failed to deploy to Cloud Run"
        exit 1
    }
}

# Set up monitoring
function Set-Monitoring {
    Write-Status "Setting up monitoring..."
    
    # Enable monitoring and logging
    gcloud services enable monitoring.googleapis.com --quiet
    gcloud services enable logging.googleapis.com --quiet
    
    Write-Success "Monitoring and logging enabled"
}

# Main deployment function
function Start-Deployment {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Google Cloud Deployment Script (PowerShell)" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    
    Test-Prerequisites
    Set-ProjectConfiguration
    Set-DockerConfiguration
    Build-AndPush
    Deploy-ToCloudRun
    Set-Monitoring
    
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Success "Deployment completed successfully!"
    Write-Host "==========================================" -ForegroundColor Cyan
    
    # Display next steps
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Visit your application URL to verify it's working"
    Write-Host "2. Set up a custom domain if needed"
    Write-Host "3. Configure monitoring alerts"
    Write-Host "4. Set up billing alerts to monitor costs"
    Write-Host ""
    Write-Host "To update your application in the future, simply run this script again."
}

# Run the main function
Start-Deployment 