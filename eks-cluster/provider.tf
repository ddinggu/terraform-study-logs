# Terraform Provider 설정

terraform {
  required_version = "1.4.2" # Terraform 엔진 버전

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}
