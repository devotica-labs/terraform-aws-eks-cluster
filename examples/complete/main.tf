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

  # Cluster name composes from null-label: dvtca-aps1-prod-payments
  namespace   = "dvtca"
  environment = "aps1"
  stage       = "prod"
  name        = "payments"

  subnet_ids = [
    "subnet-aaaaaaaaaaaaaaaaa",
    "subnet-bbbbbbbbbbbbbbbbb",
    "subnet-ccccccccccccccccc",
  ]

  kubernetes_version = "1.31"

  # IRSA / OIDC provider (also the Devotica default).
  oidc_provider_enabled = true

  # Kubernetes Secrets envelope encryption — let the module mint a dedicated
  # KMS key (rotation on, 30-day deletion window).
  cluster_encryption_config_enabled = true

  # Encrypt the control-plane CloudWatch log group with a workload KMS key
  # (e.g. a terraform-aws-kms output). All five log types are on by default.
  cloudwatch_log_group_kms_key_id = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"

  # Core EKS-managed add-ons.
  addons = [
    { addon_name = "vpc-cni" },
    { addon_name = "coredns" },
    { addon_name = "kube-proxy" },
  ]

  # Source security groups allowed to reach the EKS-managed cluster SG
  # (e.g. a bastion / VPN appliance). The API endpoint stays private.
  allowed_security_group_ids = ["sg-0bastion0000000000"]

  # Grant a platform-admin IAM role cluster-admin via an EKS access entry
  # (authentication_mode = "API", the default — no aws-auth ConfigMap).
  access_entry_map = {
    "arn:aws:iam::111122223333:role/platform-admin" = {
      access_policy_associations = {
        ClusterAdmin = {}
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = "payments"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-eks-cluster"
  }
}
