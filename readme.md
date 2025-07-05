# Facebook Automation Tool - Google Cloud Deployment

This project contains an interactive web application for Facebook automation tools, designed to help users find the perfect automation solution for their needs.

## 🚀 Quick Start - Deploy to Google Cloud

### Option 1: Automated Deployment (Recommended)

1. **Install Prerequisites**:
   - [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) - Download the Windows installer
   - [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)

2. **Initialize Google Cloud**:
   ```powershell
   gcloud init
   ```

3. **Run the Deployment Script**:
   
   **For PowerShell (Recommended)**:
   ```powershell
   .\deploy.ps1
   ```
   
   **For Command Prompt**:
   ```cmd
   deploy.bat
   ```
   
   **For Git Bash/WSL**:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

### Option 2: Manual Deployment

Follow the detailed step-by-step guide in [`cloud-deployment-guide.md`](cloud-deployment-guide.md)

## 📁 Project Structure

```
meridian-realstate/
├── guide_to_facebook_comment_automation.html  # Main web application
├── Dockerfile                                 # Container configuration
├── deploy.sh                                  # Linux/Mac deployment script
├── deploy.ps1                                 # Windows PowerShell deployment script
├── deploy.bat                                 # Windows Command Prompt deployment script
├── cloudbuild.yaml                           # Cloud Build configuration
├── cloud-deployment-guide.md                 # Detailed deployment guide
└── .dockerignore                             # Docker ignore file
```

## 🌟 Features

- **Interactive Tool Finder**: Personalized recommendations based on budget, skills, and goals
- **Comparison Dashboard**: Dynamic cost analysis and feature comparison
- **Tool Profiles**: Detailed analysis of each automation tool
- **Best Practices**: Implementation guides and tips
- **Responsive Design**: Works on desktop and mobile devices

## 💰 Cost Estimation

- **Cloud Run (Recommended)**: $5-15/month for typical usage
- **Free Tier**: 2 million requests/month included
- **Pay-per-use**: Only pay for actual usage

## 🔧 Local Development

To run locally for development:

**Using Python (Windows)**:
```powershell
# Using Python's built-in server
python -m http.server 8000

# Or if you have Python 3 specifically
python3 -m http.server 8000
```

**Using Node.js (Windows)**:
```powershell
# Install serve globally if you haven't
npm install -g serve

# Run the server
npx serve .
```

**Using Docker (Windows)**:
```powershell
# Build the Docker image
docker build -t facebook-automation-tool .

# Run the container
docker run -p 8080:80 facebook-automation-tool
```

## 📊 Benefits of Cloud Deployment

1. **No Local Resources**: Runs entirely in the cloud
2. **Automatic Scaling**: Handles traffic spikes
3. **High Availability**: 99.9% uptime SLA
4. **Global CDN**: Fast loading worldwide
5. **Automatic SSL**: HTTPS enabled by default
6. **Monitoring**: Built-in logging and monitoring
7. **Cost Effective**: Pay only for what you use

## 🔄 Updates and Maintenance

### Update the Application

```powershell
# Make your changes to the HTML file
# Then run the deployment script again
.\deploy.ps1
```

### View Logs

```powershell
gcloud run logs read facebook-automation-tool --region us-central1
```

### Monitor Costs

```powershell
gcloud billing budgets create --billing-account=YOUR_BILLING_ACCOUNT `
  --display-name="Facebook Automation Budget" `
  --budget-amount=50USD
```

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Denied**: Run `gcloud auth login`
2. **Image Not Found**: Ensure you've pushed the image to GCR
3. **Service Unavailable**: Check Cloud Run quotas and limits
4. **Docker Not Running**: Make sure Docker Desktop is started on Windows
5. **PowerShell Execution Policy**: If scripts won't run, use:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### Windows-Specific Considerations

- **Docker Desktop**: Ensure Docker Desktop is running before using Docker commands
- **WSL2**: If using WSL2, make sure it's enabled and updated
- **Antivirus**: Some antivirus software may interfere with Docker or gcloud commands
- **Firewall**: Ensure Windows Firewall allows Docker and gcloud connections

### Useful Commands

```powershell
# Check service status
gcloud run services describe facebook-automation-tool --region us-central1

# View recent deployments
gcloud run revisions list --service facebook-automation-tool --region us-central1

# Check billing
gcloud billing accounts list

# Check Docker status (Windows)
docker version
docker info
```

## 📚 Documentation

- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Google Cloud CLI Documentation](https://cloud.google.com/sdk/docs)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)

## 🤝 Contributing

1. Fork the repository
2. Make your changes
3. Test locally
4. Deploy to your own Google Cloud project
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Ready to deploy?** Run `.\deploy.ps1` to get started! 🚀
