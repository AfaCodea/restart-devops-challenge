# Next.js Deployment Guide

## Overview
This infrastructure deploys a Next.js fullstack web application (webshoesstore) on AWS EC2 using Terraform.

## Architecture
- **EC2 Instance**: t3.micro running Amazon Linux 2023
- **Web Server**: Nginx as reverse proxy
- **Application Server**: Next.js running on port 3000 via PM2
- **Security**: Security group allowing ports 22 (SSH), 80 (HTTP), and 3000 (Next.js)

## Deployment Process

### 1. Prerequisites
- AWS CLI configured with credentials (profile: `restart`)
- Terraform installed
- Git repository contains:
  - `main.tf` - Terraform configuration
  - `webshoesstore/` - Next.js application
  - `webshoesstore/.next/` - Pre-built Next.js production build

### 2. Build Next.js Locally
Before deploying, ensure the Next.js app is built:
```bash
cd webshoesstore
npm run build
cd ..
```

### 3. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review changes
terraform plan

# Deploy
terraform apply
```

### 4. Access the Application
After deployment completes (typically 5-10 minutes for full initialization):
- Get the public IP from Terraform output: `terraform output instance_public_ip`
- Access the website at: `http://<PUBLIC_IP>`

## User Data Script Details

The EC2 instance runs the following initialization script:

1. **System Update**: Updates all packages
2. **Git Installation**: Installs Git
3. **Node.js Setup**: Installs Node.js 20.x LTS
4. **PM2 Installation**: Installs PM2 process manager globally
5. **Repository Clone**: Clones the GitHub repository
6. **Dependencies**: Runs `npm install` in the webshoesstore directory
7. **Build**: Runs `npm run build` to create production build
8. **PM2 Start**: Starts Next.js app with PM2 (auto-restart enabled)
9. **Nginx Setup**: Installs and configures Nginx as reverse proxy
10. **Service Start**: Enables and starts Nginx

## Monitoring

### Check PM2 Status
SSH into the instance and run:
```bash
pm2 status
pm2 logs webshoesstore
```

### Check Nginx Status
```bash
sudo systemctl status nginx
```

### Check Application Logs
```bash
# PM2 logs
pm2 logs webshoesstore

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

## Troubleshooting

### Application Not Loading
1. Check if PM2 process is running: `pm2 status`
2. Check PM2 logs: `pm2 logs webshoesstore`
3. Verify Nginx is running: `sudo systemctl status nginx`
4. Check Nginx configuration: `sudo nginx -t`

### Port Issues
- Ensure security group allows ports 80 and 3000
- Verify Nginx is listening on port 80: `sudo netstat -tlnp | grep 80`
- Verify Next.js is listening on port 3000: `sudo netstat -tlnp | grep 3000`

## Cleanup
To destroy all resources:
```bash
terraform destroy
```

## Repository Structure
```
.
├── main.tf                 # Terraform main configuration
├── terraform.tf            # Terraform provider configuration
├── .gitignore             # Git ignore rules
├── webshoesstore/         # Next.js application
│   ├── .next/             # Production build (included in repo)
│   ├── app/               # Next.js app directory
│   ├── components/        # React components
│   ├── public/            # Static assets
│   ├── package.json       # Node dependencies
│   └── ...
└── DEPLOYMENT.md          # This file
```

## Notes
- The `.next/` build directory is committed to the repository to speed up deployment
- The user_data script may take 5-10 minutes to complete
- Use `user_data_replace_on_change = true` to force instance replacement when script changes
- For production, consider using an Application Load Balancer and Auto Scaling Group
