variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "instance_info" {
  default = {
    ami_id        = "ami-04341a215040f91bb"
    instance_type = "t3.nano"
  }
}

variable "key_pair_id" {
  sensitive = true
  type      = string
}

variable "enable_log" {
  type    = bool
  default = false
}

variable "enable_banner" {
  type    = bool
  default = false
}
