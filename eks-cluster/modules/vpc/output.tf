output "vpc_id" {
  description = "EKS VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "VPC 서브넷 ID"
  value       = module.vpc.private_subnets
}
