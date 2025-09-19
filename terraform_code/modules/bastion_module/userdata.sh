#!/bin/bash
# Bootstrap script for Ubuntu Bastion Host

# Update system and install packages
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y openssh-client git htop curl unzip

# Create known_hosts file to prevent SSH prompts
sudo mkdir -p /home/ubuntu/.ssh
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# DB server known hosts
%{ for ip in db_ips ~}
ssh-keyscan -H ${ip} >> /home/ubuntu/.ssh/known_hosts
%{ endfor ~}

# App server IPs
%{ for ip in app_ips ~}
ssh-keyscan -H ${ip} >> /home/ubuntu/.ssh/known_hosts
%{ endfor ~}


# Download private key from S3
sudo curl -o /home/ubuntu/key-pair.pem "https://my-custom-three-tier-app-bucket.s3.amazonaws.com/key-pair.pem"

# Secure the key
sudo chmod 400 /home/ubuntu/key-pair.pem
sudo chown ubuntu:ubuntu /home/ubuntu/key-pair.pem



: << 'BLOCK_COMMENT'
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  #Download the AWS CLI v2 installer
unzip awscliv2.zip  # Unzip the installer
sudo ./aws/install  # Run the install script
export PATH=$PATH:/usr/local/bin 
aws --version
BLOCK_COMMENT