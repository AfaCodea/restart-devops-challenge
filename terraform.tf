terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Konfigurasi Provider AWS
provider "aws" {
  region  = "ap-southeast-3" # Jakarta region
  profile = "restart"         # Menggunakan profile restart dari AWS CLI
}