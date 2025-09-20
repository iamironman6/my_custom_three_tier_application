#!/bin/bash
# DB Server bootstrap - Ubuntu

set -e

# Update and install required packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y mysql-server curl unzip

# Enable and start MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Wait until MySQL is ready
until sudo mysqladmin ping &>/dev/null; do
  echo "Waiting for MySQL to be ready..."
  sleep 2
done

# Define DB config from Terraform variables
db_name="${db_name}"
db_user="${db_user}"
db_pass="${db_pass}"

# Create database and user
sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`${db_name}\`;"
sudo mysql -e "CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download and import schema
cd /tmp
sudo curl -L -o db.zip https://github.com/iamironman6/my_custom_three_tier_application/archive/refs/heads/main.zip
sudo unzip db.zip

# Import schema into created DB
sudo mysql "${db_name}" < my_custom_three_tier_application-main/terraform_code/db_files/schema.sql
