module "test-env" {
  source = "./private_subnet_instances"

  vpc_cidr      = var.vpc_cidr
  subnet_cidrs  = var.subnet_cidrs
  key_pair_id   = var.key_pair_id
  instance_info = var.instance_info
}

module "client-vpn" {
  source = "./ec2_client_vpn"

  private_subnet_ids   = module.test-env.private_subnet_ids
  private_subnet_cidrs = module.test-env.private_subnet_cidrs
  vpc_cidr             = module.test-env.vpc_cidr

  enable_log    = var.enable_log
  enable_banner = var.enable_banner
}
