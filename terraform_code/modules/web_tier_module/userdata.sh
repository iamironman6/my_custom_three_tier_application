#!/bin/bash
# Web Server bootstrap - Ubuntu

apt update -y && apt upgrade -y
apt install -y nginx awscli


# Create web root dir and download frontend files from S3
mkdir -p /var/www/html
aws s3 sync s3://my-custom-three-tier-app-bucket/frontend_files /var/www/html

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx


# Replace this with the actual ALB DNS name passed via Terraform
APP_ALB_DNS_NAME="${app_alb_dns_name}"

# Replace default nginx config to add reverse proxy to App Tier ALB
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        root /var/www/html;
        index index.html;
    }

    location /api/ {
        proxy_pass http://${APP_ALB_DNS_NAME};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Restart nginx to apply the config
sudo systemctl restart nginx
