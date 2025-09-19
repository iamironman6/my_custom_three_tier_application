#!/bin/bash
# App Server bootstrap - Ubuntu

# Update OS and install required packages
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-pip curl unzip


# Download backend files from public GitHub repo
cd /tmp
sudo curl -L -o backend.zip https://github.com/iamironman6/my_custom_three_tier_application/archive/refs/heads/main.zip
sudo unzip backend.zip

# need index.html file also, have to check if it is needed or not

# Move backend files to app directory
sudo mkdir -p /opt/myapp
sudo mv my_custom_three_tier_application-main/terraform_code/backend_files/* /opt/myapp

# Install Python dependencies
#sudo pip3 install -r /opt/myapp/requirements.txt

sudo apt-get install python3-full -y
sudo chown -R ubuntu:ubuntu /opt/myapp
cd /opt/myapp
sudo python3 -m venv venv
source venv/bin/activate
pip install Flask==2.2.5 mysql-connector-python==8.3.0 boto3==1.34.79
pip list

# Create systemd service for Flask app
cat <<EOF | sudo tee /etc/systemd/system/flaskapp.service > /dev/null
[Unit]
Description=Flask App
After=network.target

[Service]
Environment=DB_HOST=your-mysql-endpoint
Environment=DB_USER=myuser
Environment=DB_PASS=mypassword
Environment=DB_NAME=myapp
ExecStart=/opt/myapp/venv/bin/python /opt/myapp/app.py
WorkingDirectory=/opt/myapp
Restart=always
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Flask app
sudo systemctl daemon-reload
sudo systemctl enable flaskapp
sudo systemctl start flaskapp


#journalctl -u flaskapp.service --no-pager -n 30