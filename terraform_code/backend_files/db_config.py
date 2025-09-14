import os

DB_CONFIG = {
    'host': os.environ['DB_HOST'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASS'],
    'database': os.environ['DB_NAME']
}


# Use Terraform to inject real values or load from environment.