#!/bin/bash
# App Server bootstrap - Ubuntu

apt update -y && apt upgrade -y
apt install -y python3 python3-pip awscli

# Download backend files from S3
mkdir -p /opt/myapp
aws s3 sync s3://my-custom-three-tier-app-bucket/backend_files /opt/myapp

# Install Python packages from requirements.txt
pip3 install -r /opt/myapp/requirements.txt

# Set environment variables
echo 'DB_HOST=<your-mysql-endpoint-or-private-IP>' >> /etc/environment
echo 'DB_USER=myuser' >> /etc/environment
echo 'DB_PASS=mypassword' >> /etc/environment
echo 'DB_NAME=myapp' >> /etc/environment

# Create systemd service
cat <<EOF > /etc/systemd/system/flaskapp.service
[Unit]
Description=Flask App
After=network.target

[Service]
EnvironmentFile=-/etc/environment
ExecStart=/usr/bin/python3 /opt/myapp/app.py
WorkingDirectory=/opt/myapp
Restart=always
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF

# Start flask app
sudo systemctl daemon-reload
sudo systemctl enable flaskapp
sudo systemctl start flaskapp
