

terraform {
  backend "s3" {
    bucket         = "tfstate-bucket-d4b720ed"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
