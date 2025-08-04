terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "Cloud-Intern-484907516017"
  allowed_account_ids = ["484907516017"]
}