output "eks_cluster_id" {
  description = "EKS cluster name."
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_oidc_issuer_arn" {
  description = "OIDC provider ARN for binding IRSA roles."
  value       = module.eks.eks_cluster_identity_oidc_issuer_arn
}
