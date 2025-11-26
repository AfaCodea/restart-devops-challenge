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
  region  = "ap-southeast-2" # Sidney region
  profile = "restart"         # Menggunakan profile restart dari AWS CLI
}