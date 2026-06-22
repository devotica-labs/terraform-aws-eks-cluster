terraform {
  # >= 1.5.0 for `check` blocks (used in main.tf for the fintech guardrails).
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.25.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0, != 4.0.0"
    }
  }
}
