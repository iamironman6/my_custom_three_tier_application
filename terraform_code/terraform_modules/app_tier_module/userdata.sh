#!/bin/bash
# App Server bootstrap - Ubuntu

apt update -y && apt upgrade -y
apt install -y python3 python3-pip awscli

pip3 install -r /tmp/requirements.txt

# Download backend files from S3
mkdir -p /opt/myapp
aws s3 sync s3://my-custom-three-tier-app-bucket/backend_files /opt/myapp

# Install Python packages from requirements.txt
pip3 install -r /opt/myapp/requirements.txt

# Create systemd service
cat <<EOF > /etc/systemd/system/flaskapp.service
[Unit]
Description=Flask App
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/myapp/app.py
WorkingDirectory=/opt/myapp
Restart=always
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF

# Start flask app
systemctl daemon-reload
systemctl enable flaskapp
systemctl start flaskapp
