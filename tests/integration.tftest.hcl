# Integration tests — apply + assert + destroy.
# Requires real AWS credentials AND pre-existing private subnets in the VPC.
# Triggered via workflow_dispatch on integration.yml. Creating a real EKS
# control plane takes ~10-15 minutes, so keep this lean.

provider "aws" {
  region = "ap-south-1"
}

variables {
  namespace  = "dvtca"
  stage      = "integ"
  name       = "eks"
  subnet_ids = []

  # Keep the run cheap + fast: no add-ons, no public endpoint.
  kubernetes_version = "1.31"

  tags = { Environment = "integration-test", Ephemeral = "true" }
}

run "apply_and_assert" {
  command = apply

  assert {
    condition     = aws_eks_cluster.default[0].arn != ""
    error_message = "EKS cluster must be created."
  }
  assert {
    condition     = aws_eks_cluster.default[0].vpc_config[0].endpoint_public_access == false
    error_message = "Public API endpoint must be off."
  }
  assert {
    condition     = length(aws_iam_openid_connect_provider.default) == 1
    error_message = "OIDC provider must be created for IRSA."
  }
  assert {
    condition     = aws_eks_cluster.default[0].deletion_protection == true
    error_message = "Deletion protection must be on."
  }
}
