provider "aws" {
  region     = var.region #"us-east-1"                                # Define your AWS region
  access_key = ""         # Replace with your AWS Access Key
  secret_key = ""         # Replace with your AWS Secret Access Key
}



terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.81"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}


