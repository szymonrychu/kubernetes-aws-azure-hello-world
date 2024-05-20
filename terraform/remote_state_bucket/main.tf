terraform {
  required_version = ">=v1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.9.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}
