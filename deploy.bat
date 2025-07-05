@echo off
REM Google Cloud Deployment Script for Facebook Automation Tool (Windows Batch)
REM This script automates the deployment process to Google Cloud Platform

echo 🚀 Starting Google Cloud Deployment...

REM Check if gcloud is installed
where gcloud >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Google Cloud CLI is not installed. Please install it first.
    echo Download from: https://cloud.google.com/sdk/docs/install
    pause
    exit /b 1
)

REM Check if docker is installed
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop for Windows first.
    echo Download from: https://docs.docker.com/desktop/install/windows-install/
    pause
    exit /b 1
)

REM Check if Docker Desktop is running
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Desktop is not running. Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo [SUCCESS] All prerequisites are installed and running

REM Get current project
for /f "tokens=*" %%i in ('gcloud config get-value project 2^>nul') do set PROJECT_ID=%%i

if "%PROJECT_ID%"=="" (
    echo [WARNING] No project is set. Please run 'gcloud init' first.
    set /p PROJECT_ID="Enter your project ID: "
    gcloud config set project %PROJECT_ID%
)

echo [SUCCESS] Using project: %PROJECT_ID%

REM Enable required APIs
echo [INFO] Enabling required APIs...
gcloud services enable cloudbuild.googleapis.com --quiet
gcloud services enable run.googleapis.com --quiet
gcloud services enable containerregistry.googleapis.com --quiet
echo [SUCCESS] APIs enabled successfully

REM Configure Docker for Google Cloud
echo [INFO] Configuring Docker for Google Cloud...
gcloud auth configure-docker --quiet
echo [SUCCESS] Docker configured for Google Cloud

REM Build Docker image
echo [INFO] Building Docker image...
docker build -t gcr.io/%PROJECT_ID%/facebook-automation-tool .
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build Docker image
    pause
    exit /b 1
)
echo [SUCCESS] Docker image built successfully

REM Push image to Google Container Registry
echo [INFO] Pushing image to Google Container Registry...
docker push gcr.io/%PROJECT_ID%/facebook-automation-tool
if %errorlevel% neq 0 (
    echo [ERROR] Failed to push image
    pause
    exit /b 1
)
echo [SUCCESS] Image pushed successfully

REM Deploy to Cloud Run
echo [INFO] Deploying to Cloud Run...
gcloud run deploy facebook-automation-tool ^
    --image gcr.io/%PROJECT_ID%/facebook-automation-tool ^
    --platform managed ^
    --region us-central1 ^
    --allow-unauthenticated ^
    --port 80 ^
    --memory 512Mi ^
    --cpu 1 ^
    --max-instances 10 ^
    --min-instances 0

if %errorlevel% neq 0 (
    echo [ERROR] Failed to deploy to Cloud Run
    pause
    exit /b 1
)
echo [SUCCESS] Deployed to Cloud Run successfully

REM Get the service URL
for /f "tokens=*" %%i in ('gcloud run services describe facebook-automation-tool --region us-central1 --format="value(status.url)"') do set SERVICE_URL=%%i
echo [SUCCESS] Your application is available at: %SERVICE_URL%

REM Enable monitoring and logging
echo [INFO] Setting up monitoring...
gcloud services enable monitoring.googleapis.com --quiet
gcloud services enable logging.googleapis.com --quiet
echo [SUCCESS] Monitoring and logging enabled

echo ==========================================
echo [SUCCESS] Deployment completed successfully!
echo ==========================================
echo.
echo Next steps:
echo 1. Visit your application URL to verify it's working
echo 2. Set up a custom domain if needed
echo 3. Configure monitoring alerts
echo 4. Set up billing alerts to monitor costs
echo.
echo To update your application in the future, simply run this script again.
pause 