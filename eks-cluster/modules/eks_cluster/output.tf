output "cluster_endpoint" {
  description = "EKS 컨트롤 플레인 API 서버 엔드포인트"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "EKS SG ID"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "EKS 클러스터 명"
  value       = module.eks.cluster_name
}

output "cluster_id" {
  description = "EKS 클러스터 id"
  value       = module.eks.cluster_id
}

output "oidc_provider_arn" {
  description = "EKS OIDC Provider"
  value       = module.eks.oidc_provider_arn
}
