#!/bin/bash
# Basic user data for Bastion Host (secure version)

# Update system packages
yum update -y

# Install SSH client tools
yum install -y openssh-clients git htop

# (Optional) Pre-scan known hosts for App and DB servers
APP_SERVER_IP="<APP_SERVER_PRIVATE_IP>"
DB_SERVER_IP="<DB_SERVER_PRIVATE_IP>"

ssh-keyscan -H $APP_SERVER_IP >> /home/ec2-user/.ssh/known_hosts
ssh-keyscan -H $DB_SERVER_IP >> /home/ec2-user/.ssh/known_hosts

# Done — admin will use their own SSH key to connect via Bastion
