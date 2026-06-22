output "eks_cluster_id" {
  description = "EKS cluster name."
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.eks_cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_oidc_issuer_arn" {
  description = "OIDC provider ARN for binding IRSA roles."
  value       = module.eks.eks_cluster_identity_oidc_issuer_arn
}

output "eks_cluster_role_arn" {
  description = "EKS cluster IAM service role ARN."
  value       = module.eks.eks_cluster_role_arn
}

output "eks_cluster_managed_security_group_id" {
  description = "EKS-managed cluster security group ID."
  value       = module.eks.eks_cluster_managed_security_group_id
}

output "cluster_encryption_config_provider_key_alias" {
  description = "KMS alias ARN for the secrets-encryption key."
  value       = module.eks.cluster_encryption_config_provider_key_alias
}
