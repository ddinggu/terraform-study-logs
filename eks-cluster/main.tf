module "eks_vpc" {
  source = "./modules/vpc"

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  cluster_name    = var.cluster_name
}

module "eks" {
  source = "./modules/eks_cluster"

  vpc_id     = module.eks_vpc.vpc_id
  subnet_ids = module.eks_vpc.subnet_ids

  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  aws_auth_users            = var.aws_auth_users
  aws_auth_accounts         = var.aws_auth_accounts

  argocd_config = var.argocd_config
}

module "efs" {
  source = "./modules/efs"

  vpc_id     = module.eks_vpc.vpc_id
  subnet_ids = module.eks_vpc.subnet_ids
  vpc_cidr   = var.vpc_cidr

  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_name          = module.eks.cluster_name
  cluster_oidc_provider = module.eks.oidc_provider_arn
}
