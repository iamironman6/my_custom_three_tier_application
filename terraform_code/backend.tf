terraform {
  backend "s3" {
    bucket = "my-custom-three-tier-app-bucket"
    key = "state_files/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}