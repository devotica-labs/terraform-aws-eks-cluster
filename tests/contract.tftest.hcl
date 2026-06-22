# Contract tests — naming + output surface stay stable across minor/patch versions.

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
  namespace         = "dvtca"
  stage             = "test"
  name              = "contract"
  subnet_ids        = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
  service_ipv4_cidr = "172.20.0.0/16"
}

run "cluster_name_composed_from_segments" {
  command = plan
  # the default cluster_attributes = ["cluster"], so the id
  # is namespace-stage-name-cluster.
  assert {
    condition     = aws_eks_cluster.default[0].name == "dvtca-test-contract-cluster"
    error_message = "Cluster name must compose namespace-stage-name-cluster via name segments."
  }
}

run "kubernetes_version_pinned" {
  command = plan
  assert {
    condition     = aws_eks_cluster.default[0].version == "1.31"
    error_message = "Default Kubernetes version must be the pinned 1.31."
  }
}

run "log_group_naming_stable" {
  command = plan
  assert {
    condition     = aws_cloudwatch_log_group.default[0].name == "/aws/eks/dvtca-test-contract-cluster/cluster"
    error_message = "Log group must be /aws/eks/<cluster>/cluster."
  }
}

run "encryption_config_targets_secrets" {
  command = plan
  assert {
    condition     = contains(aws_eks_cluster.default[0].encryption_config[0].resources, "secrets")
    error_message = "Cluster encryption config must cover Kubernetes secrets."
  }
}

run "authentication_mode_is_api" {
  command = plan
  assert {
    condition     = aws_eks_cluster.default[0].access_config[0].authentication_mode == "API"
    error_message = "Cluster must use API authentication mode (no aws-auth ConfigMap)."
  }
}

run "creator_admin_permissions_off" {
  command = plan
  assert {
    condition     = aws_eks_cluster.default[0].access_config[0].bootstrap_cluster_creator_admin_permissions == false
    error_message = "Creator admin permissions must be off (least privilege)."
  }
}
