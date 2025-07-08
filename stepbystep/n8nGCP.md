# N8N Installation Tutorial

## Step 1: Introduction to N8N

First, the video explains that **N8N** is a powerful AI automation tool. It can automate workflows, connect with various platforms, and even manage your emails. Unlike large language models such as ChatGPT, N8N is designed for repetitive task execution without needing constant manual input.

---

## Step 2: Google Cloud Setup

Next, you will set up your Google Cloud environment.

*   **Login and Billing**: Go to [console.cloud.google.com](http://console.cloud.google.com) and log in. You will need to set up a billing account by linking a credit or debit card.
*   **Create a New Project**: Create a new project in your Google Cloud console.
*   **Enable Compute Engine API**: Navigate to the **Compute Engine** section and enable the API.
*   **Create a VM Instance**:
    *   Create a new VM instance. For the free tier, select an **E2 micro** instance located in a US region (e.g., US Central 1).
    *   Set the boot disk to a **30GB standard persistent disk**.
    *   Under **Firewall**, allow both **HTTP** and **HTTPS** traffic.
    *   Click **Create** to launch your new VM.

---

## Step 3: N8N Installation via SSH

Now, you will connect to your VM and install N8N.

*   **Connect via SSH**: Open an SSH connection to your VM.
*   **Update Packages**: Update your system's packages with the following command:
    ```bash
    sudo apt update
    ```
*   **Install Docker**: Install Docker, which is used to run N8N in a container:
    ```bash
    sudo apt install docker.io
    ```
*   **Start and Enable Docker**: Start the Docker service and enable it to run on startup:
    ```bash
    sudo systemctl start docker
    sudo systemctl enable docker
    ```
*   **Install N8N**: Run the following command to download and run the N8N Docker container. **Remember to replace `yourdomain.com` with your actual domain or subdomain.**
    ```bash
    docker run -it --rm --name n8n -p 5678:5678 -e N8N_HOST=yourdomain.com -e N8N_PROTOCOL=https -e WEBHOOK_URL=https://yourdomain.com/ -v ~/.n8n:/home/node/.n8n n8n/n8n
    ```

---

## Step 4: DNS Configuration

You will need a domain name for your N8N instance.

*   **Point Domain to VM**: In your domain registrar's DNS settings (the video uses Cloudflare as an example), create an **"A" record** that points your chosen domain or subdomain to the **external IP address** of your Google Cloud VM.

---

## Step 5: Install Nginx and SSL

To secure your N8N instance with a free SSL certificate, you will install Nginx and Certbot.

*   **Install Nginx**:
    ```bash
    sudo apt install nginx
    ```
*   **Create Nginx Config File**:
    ```bash
    sudo nano /etc/nginx/sites-available/n8n.conf
    ```
    Add the following server block configuration to this file, again replacing `yourdomain.com` with your domain:
    ```nginx
    server {
        listen 80;
        server_name yourdomain.com;
        location / {
            proxy_pass http://localhost:5678;
            proxy_set_header Connection '';
            proxy_http_version 1.1;
            chunked_transfer_encoding off;
            proxy_buffering off;
            proxy_cache off;
        }
    }
    ```
*   **Enable Configuration and Restart Nginx**:
    ```bash
    sudo ln -s /etc/nginx/sites-available/n8n.conf /etc/nginx/sites-enabled/
    sudo systemctl restart nginx
    ```
*   **Install Certbot and Request SSL Certificate**:
    ```bash
    sudo apt install certbot python3-certbot-nginx
    sudo certbot --nginx -d yourdomain.com
    ```
    You will be prompted to enter your email address for certificate renewal notices.

---

## Step 6: Verify and Use N8N

*   **Verify N8N Instance**: You can now access your N8N instance by navigating to your domain (e.g., `https://n8n.yourdomain.com`). You will be prompted to create an account.
*   **Importing Workflows**: The video also demonstrates how you can copy pre-built workflow templates from the N8N website and paste them directly into your new N8N instance to get started quickly.

Enjoy your new, self-hosted N8N instance! You can find the original video here for a visual guide: [https://youtu.be/x49ZiJDIVPQ?si=m6C8LJ29FyAOlvhu](https://youtu.be/x49ZiJDIVPQ?si=m6C8LJ29FyAOlvhu) 