locals {
  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id
  vpc_cidr   = var.vpc_cidr

  cluster_name          = var.cluster_name
  cluster_oidc_provider = var.cluster_oidc_provider
}

resource "aws_security_group" "efs_sg" {
  name        = "eks-cluster-nfs"
  description = "nfs mounts sg for EKS cluster"
  vpc_id      = local.vpc_id

  ingress {
    description = "nfs mounts sg for EKS cluster"
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    cidr_blocks = [local.vpc_cidr]
  }
}

resource "aws_efs_file_system" "efs_fs" {
  creation_token = "eks-cluster-nfs"

  encrypted        = true             # 암호화
  performance_mode = "generalPurpose" # 성능: generalPurpose(범용 모드), maxIO(최대 IO 모드)
  throughput_mode  = "bursting"       # 처리량: busrsting(버스팅 모드), provisioned(처리량 프로비저닝)

  # 수명 주기 관리 
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" # 특정 시간 이후 IA(Standard-Infrequent Access)로 전환
  }

  tags = {
    Name = "eks-cluster-nfs"
  }
}

# EFS 서브넷 별 마운트 타겟 지정: 워커노드(프라이빗 서브넷)와 동일하게 지정
resource "aws_efs_mount_target" "efs_mount" {
  count = length(local.subnet_ids)

  subnet_id       = local.subnet_ids[count.index]
  file_system_id  = aws_efs_file_system.efs_fs.id
  security_groups = [aws_security_group.efs_sg.id]
}

# efs-csi-controller에게 EFS IAM role assume 부여
# https://github.com/terraform-aws-modules/terraform-aws-iam/blob/v5.27.0/modules/iam-role-for-service-accounts-eks/main.tf
module "efs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.27.0"

  create_role           = true
  role_name             = "AmazonEKSTFEKSCSIRole-${local.cluster_name}"
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = local.cluster_oidc_provider
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  depends_on = [aws_efs_mount_target.efs_mount]
}
