#!/bin/bash
# Web Server bootstrap - Ubuntu

set -e  # Exit on any failure
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

# Update packages and install necessary tools
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y curl unzip nginx git

# Download frontend files from GitHub
cd /tmp
sudo curl -L -o frontend.zip https://github.com/iamironman6/my_custom_three_tier_application/archive/refs/heads/main.zip
sudo unzip frontend.zip

# Move frontend files to nginx root (adjusted path from your GitHub repo)
sudo mkdir -p /var/www/html
sudo mv my_custom_three_tier_application-main/terraform_code/frontend_files/* /var/www/html/

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

#Use the App ALB DNS name passed from Terraform
app_alb_dns_name="${app_alb_dns_name}"
echo "App ALB DNS Name: ${app_alb_dns_name}"

# Configure nginx reverse proxy to App Tier ALB
cat <<EOF | sudo tee /etc/nginx/sites-available/default > /dev/null
server {
    listen 80;
    server_name _;

    location / {
        root /var/www/html;
        index index.html;
    }

    location /api/ {
        proxy_pass http://${app_alb_dns_name};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo systemctl status nginx

