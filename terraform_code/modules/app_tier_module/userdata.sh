#!/bin/bash
set -e

# Logging
exec > >(tee /var/log/userdata_app.log | logger -t userdata_app -s 2>/dev/console) 2>&1

# Update and install required packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-pip curl unzip netcat python3-venv

# Install AWS CLI v2
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI with root credentials injected via Terraform
aws configure set aws_access_key_id ${aws_root_access_key}
aws configure set aws_secret_access_key ${aws_root_secret_key}
aws configure set default.region us-east-1

# Download backend files
cd /tmp
sudo curl -L -o backend.zip https://github.com/iamironman6/my_custom_three_tier_application/archive/refs/heads/main.zip
sudo unzip backend.zip

# Move backend files
sudo mkdir -p /opt/myapp
sudo mv my_custom_three_tier_application-main/terraform_code/backend_files/* /opt/myapp
sudo chown -R ubuntu:ubuntu /opt/myapp

cd /opt/myapp

# Create virtualenv & install dependencies
python3 -m venv venv
source venv/bin/activate
pip install Flask==2.2.5 mysql-connector-python==8.3.0 boto3==1.34.79

# Wait for DB reachability
echo "Waiting for DB at ${db_host}:3306..."
for i in {1..30}; do
  if nc -z ${db_host} 3306; then
    echo "DB is reachable!"
    break
  fi
  echo "Attempt ${i}: DB not reachable, retry in 5s..."
  sleep 5
done

# Optionally fail if still not reachable
if ! nc -z ${db_host} 3306; then
  echo "ERROR: DB not reachable after retries - exiting"
  exit 1
fi

sleep 5

# OR export environment variables for boto3
export AWS_ACCESS_KEY_ID=${aws_root_access_key}
export AWS_SECRET_ACCESS_KEY=${aws_root_secret_key}
export AWS_DEFAULT_REGION=us-east-1

# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/flaskapp.service > /dev/null
[Unit]
Description=Flask App
After=network.target

[Service]
Environment=DB_HOST=${db_host}
Environment=DB_USER=${db_user}
Environment=DB_PASS=${db_pass}
Environment=DB_NAME=${db_name}
ExecStart=/opt/myapp/venv/bin/python /opt/myapp/app.py
WorkingDirectory=/opt/myapp
Restart=always
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable flaskapp
sudo systemctl start flaskapp
