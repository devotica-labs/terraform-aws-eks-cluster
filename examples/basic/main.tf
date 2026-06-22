# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/eks-cluster/aws"
#   version = "~> 0.1"

module "eks" {
  source = "../.."

  # Cluster name composes from null-label: dvtca-sandbox-platform
  namespace = "dvtca"
  stage     = "sandbox"
  name      = "platform"

  subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]

  kubernetes_version = "1.31"

  # Fintech defaults already cover the rest: private-only API endpoint,
  # OIDC/IRSA on, Kubernetes Secrets envelope-encrypted with a module-minted
  # KMS key, all five control-plane log types at 365-day retention, and
  # deletion protection on.

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-eks-cluster"
    Owner       = "platform@devotica.com"
    ManagedBy   = "Terraform"
  }
}
