resource "helm_release" "aws_efs_csi_driver" {
  namespace  = "kube-system"
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  version    = "2.4.6"

  # serviceAccount에 efs_csi용 role arn 등록
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.efs_csi_irsa_role.iam_role_arn
  }

  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.efs_csi_irsa_role.iam_role_arn
  }
}

## EFS StorageClass 생성
resource "kubernetes_storage_class_v1" "efs_sc" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"

  # PV 반환 정책: Retain은 PVC 제거 시 스토리지 수동 복구 가능
  # https://kubernetes.io/ko/docs/tasks/administer-cluster/change-pv-reclaim-policy/
  reclaim_policy = "Retain"

  parameters = {
    provisioningMode = "efs-ap" # EFS는 해당 값만 지원 가능
    fileSystemId     = aws_efs_file_system.efs_fs.id
    directoryPerms   = "700"  # 엑세스 포인트의 루트 디렉토리의 권한
    gidRangeStart    = "1000" # gid 범위
    gidRangeEnd      = "2000"
    basePath         = "/dynamic_provisioning" # 엑세스 포인트 루트 디렉토리를 생성
  }

  depends_on = [helm_release.aws_efs_csi_driver, aws_efs_file_system.efs_fs]
}
