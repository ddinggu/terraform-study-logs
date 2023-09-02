data "aws_caller_identity" "available" {}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name

  depends_on = [module.eks.cluster_endpoint]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name

  depends_on = [module.eks.cluster_endpoint]
}

## karpenter ECR 이미지를 가져오기 위한 Auth token 발행(한국 리전 발행불가)
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

## ingress-nginx-aws manifest 파일 로드
data "kubectl_file_documents" "ingress_nginx_docs" {
  content = file("${path.module}/manifests/ingress_nginx_deploy.yaml")
}
