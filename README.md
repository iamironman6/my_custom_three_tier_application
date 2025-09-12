# my_custom_three_tier_application
This Repo refers to my three-tier-application
My AWS Project - 3 Tier App
This is a simple 3-tier application used for testing AWS Terraform deployments. It includes:

Frontend: HTML/CSS/JS
Backend: Python Flask API
Database: MySQL (RDS-compatible)
Features
Displays EC2 instances (App, Web, DB)
Shows CPU metrics from CloudWatch
Simple MySQL connection example
Neatly styled dashboard with AWS logo
Requirements
Python 3.8+
MySQL server (local or AWS RDS)
IAM role for EC2 with:
ec2:DescribeInstances
cloudwatch:GetMetricStatistics
