variable "vpc_name" {
  type        = string
  description = "EKS 클러스터가 구축될 VPC 명"
}

variable "vpc_cidr" {
  type        = string
  description = "EKS 클러스터가 구축될 VPC의 CIDR"

  default = "10.0.0.0/16"
}

variable "cluster_name" {
  type        = string
  description = "EKS 클러스터 명"
}

variable "cluster_version" {
  type        = string
  description = "EKS 클러스터 버전"
}

variable "public_subnets" {
  type        = list(string)
  description = "EKS 클러스터 VPC의 NAT 및 LB가 위치할 퍼블릭 서브넷"

  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "EKS 클러스터 워커노드가 위치할 프라이빗 서브넷"

  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "argocd_config" {
  type = object({
    admin_password = string
    enable_dex     = bool
    insecure       = bool
  })
  description = "argocd 차트 설정 값"

  default = {
    admin_password = ""
    enable_dex     = true
    insecure       = false
  }
}

variable "manage_aws_auth_configmap" {
  type        = bool
  description = "Terraform에서 클러스터 RBAC 관리 여부"

  default = false
}

variable "aws_auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  description = "클러스터 RBAC IAM 유저 설정"
}

variable "aws_auth_accounts" {
  type        = list(string)
  description = "클러스터 RBAC AWS 유저 Account 설정"
}
