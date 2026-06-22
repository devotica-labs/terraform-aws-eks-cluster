# Plan-only unit tests — no AWS credentials required.
#
# The aws_eks_cluster computed blocks (identity, kubernetes_network_config)
# are given mock defaults so the module's nested-index outputs evaluate.

mock_provider "aws" {
  mock_data "aws_partition" {
    defaults = { partition = "aws", dns_suffix = "amazonaws.com" }
  }
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
  mock_resource "aws_eks_cluster" {
    defaults = {
      identity = [{
        oidc = [{ issuer = "https://oidc.eks.ap-south-1.amazonaws.com/id/MOCK0000000000000000" }]
      }]
      certificate_authority     = [{ data = "TU9DSw==" }]
      kubernetes_network_config = [{ service_ipv4_cidr = "172.20.0.0/16", service_ipv6_cidr = "" }]
    }
  }
}

mock_provider "tls" {}

variables {
  namespace  = "dvtca"
  stage      = "test"
  name       = "unit"
  subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
  # Set so the kubernetes_network_config block renders (the cloudposse
  # outputs index [0] on it; under mock an empty block is known-empty, not
  # unknown). Harmless to the assertions below.
  service_ipv4_cidr = "172.20.0.0/16"
}

run "cluster_created" {
  command = plan
  assert {
    condition     = length(aws_eks_cluster.default) == 1
    error_message = "Exactly one EKS cluster must be planned."
  }
}

run "deletion_protection_on_by_default" {
  command = plan
  assert {
    condition     = aws_eks_cluster.default[0].deletion_protection == true
    error_message = "Devotica default: deletion protection must be on."
  }
}

run "private_endpoint_public_closed_by_default" {
  command = plan
  assert {
    condition     = aws_eks_cluster.default[0].vpc_config[0].endpoint_private_access == true
    error_message = "Private API endpoint must be enabled by default."
  }
  assert {
    condition     = aws_eks_cluster.default[0].vpc_config[0].endpoint_public_access == false
    error_message = "Public API endpoint must be disabled by default."
  }
}

run "all_control_plane_logs_enabled" {
  command = plan
  assert {
    condition     = length(aws_eks_cluster.default[0].enabled_cluster_log_types) == 5
    error_message = "All five control-plane log types must be enabled by default."
  }
  assert {
    condition     = contains(aws_eks_cluster.default[0].enabled_cluster_log_types, "audit")
    error_message = "The audit log type must be enabled."
  }
}

run "log_retention_365_by_default" {
  command = plan
  assert {
    condition     = aws_cloudwatch_log_group.default[0].retention_in_days == 365
    error_message = "Control-plane log retention must default to 365 days."
  }
}

run "secrets_encryption_key_created_by_default" {
  command = plan
  assert {
    condition     = length(aws_kms_key.cluster) == 1
    error_message = "A secrets-encryption KMS key must be created when none is supplied."
  }
  assert {
    condition     = aws_kms_key.cluster[0].enable_key_rotation == true
    error_message = "The secrets-encryption KMS key must have rotation enabled."
  }
}

run "byo_kms_key_skips_creation" {
  command = plan
  variables {
    cluster_encryption_config_kms_key_id = "arn:aws:kms:ap-south-1:111122223333:key/abc"
  }
  assert {
    condition     = length(aws_kms_key.cluster) == 0
    error_message = "No KMS key should be created when a key ID is supplied."
  }
}

run "service_role_created_by_default" {
  command = plan
  assert {
    condition     = length(aws_iam_role.default) == 1
    error_message = "An IAM cluster service role must be created by default."
  }
}

run "byo_service_role_skips_creation" {
  command = plan
  variables {
    create_eks_service_role      = false
    eks_cluster_service_role_arn = "arn:aws:iam::111122223333:role/my-eks-role"
  }
  assert {
    condition     = length(aws_iam_role.default) == 0
    error_message = "No service role should be created when create_eks_service_role = false."
  }
}

run "oidc_provider_created_by_default" {
  command = plan
  assert {
    condition     = length(aws_iam_openid_connect_provider.default) == 1
    error_message = "Devotica default: the OIDC provider (IRSA) must be created."
  }
}

run "oidc_provider_disabled_when_flagged" {
  command = plan
  variables {
    oidc_provider_enabled = false
  }
  assert {
    condition     = length(aws_iam_openid_connect_provider.default) == 0
    error_message = "No OIDC provider when oidc_provider_enabled = false."
  }
}
