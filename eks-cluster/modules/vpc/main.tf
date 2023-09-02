# EKS VPC Module
locals {
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  cluster_name = var.cluster_name
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.vpc_name

  cidr = local.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true

  # 로드벨런서 서비스 실행 시 ELB 리소스가 할당될 수 있도록 서브넷에 태그 추가 필수
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
    "karpenter.sh/discovery"                      = local.cluster_name # Karpenter auto-discovery를 위한 서브넷에 태그 추가
  }
}
