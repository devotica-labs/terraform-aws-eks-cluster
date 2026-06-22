terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.25"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0, != 4.0.0"
    }
  }
}
