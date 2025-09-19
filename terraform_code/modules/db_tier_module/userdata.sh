#!/bin/bash
# DB Server bootstrap - Ubuntu

# Update packages and install MySQL and required tools
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y mysql-server 
sudo apt-get install -y curl 
sudo apt-get install -y unzip

# Enable and start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Download DB schema from GitHub repo
cd /tmp
sudo curl -L -o db.zip https://github.com/iamironman6/my_custom_three_tier_application/archive/refs/heads/main.zip
sudo unzip db.zip

# Load schema into MySQL
mysql -u root < my_custom_three_tier_application-main/terraform_code/db_files/schema.sql
