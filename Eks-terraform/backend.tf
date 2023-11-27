terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-010203" # Replace with your actual S3 bucket name
    key    = "Eks/terraform.tfstate"
    region = "us-east-1"
  }
}
