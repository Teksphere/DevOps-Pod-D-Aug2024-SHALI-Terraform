terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}


terraform {
  backend "s3" {
    bucket = "shali-pkr-bucket"
    key = "environments/prod/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "shali-pkr-locks-table"
    encrypt = true
  }
}

resource "aws_s3_bucket" "terraform_state" {

    bucket = "shali-pkr-bucket"

    // This is only here so we can destroy the bucket if we need to. you should not copy this for production
    // usage
    lifecycle {
      prevent_destroy = true
    }

    # Enable versioning so we can see the full revision history of our
    # state files
    versioning {
      enabled = true
    }

    # Enable server-side encryption by default
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "shali-pkr-locks-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}