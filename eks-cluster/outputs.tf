output "cluster_name" {
  description = "EKS 클러스터 명"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS 컨트롤 플레인 API 서버 엔드포인트"
  value       = module.eks.cluster_endpoint
}
