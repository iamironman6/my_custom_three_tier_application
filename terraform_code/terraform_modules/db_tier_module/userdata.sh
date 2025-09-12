#!/bin/bash
# DB Server bootstrap - Ubuntu

apt update -y && apt upgrade -y
apt install -y mysql-server

systemctl start mysql
systemctl enable mysql

# Optional: If you want to load DB schema from backend/db_config.py or elsewhere,
# You could download SQL files similarly from S3 and import here

aws s3 cp s3://my-custom-three-tier-app-bucket/db_files/schema.sql /tmp/schema.sql
mysql -u root < /tmp/schema.sql