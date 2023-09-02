resource "kubectl_manifest" "ingress_nginx" {
  for_each  = data.kubectl_file_documents.ingress_nginx_docs.manifests
  yaml_body = each.value

  ## 클러스터 생성 후에 manifest를 등록해야하기 때문에 추가
  depends_on = [
    module.eks
  ]
}
