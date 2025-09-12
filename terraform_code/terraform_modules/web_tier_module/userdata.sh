#!/bin/bash
# Web Server bootstrap - Ubuntu

apt update -y && apt upgrade -y
apt install -y nginx awscli

# Create web root dir and download frontend files from S3
mkdir -p /var/www/html
aws s3 sync s3://my-custom-three-tier-app-bucket/frontend_files /var/www/html

# Start and enable nginx
systemctl start nginx
systemctl enable nginx
