data "aws_eks_cluster" "this" {
  name = var.cluster_name

  depends_on = [var.cluster_endpoint]
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name

  depends_on = [var.cluster_endpoint]
}
