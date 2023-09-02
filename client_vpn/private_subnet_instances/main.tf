locals {
  vpc_cidr      = var.vpc_cidr
  subnet_cidrs  = var.subnet_cidrs
  instance_info = var.instance_info
}

resource "aws_vpc" "vpn_test" {
  cidr_block = local.vpc_cidr

  tags = {
    Name  = "vpn-test-vpc"
    Stage = "dev"
  }
}

resource "aws_subnet" "vpn_test" {
  count = 2

  vpc_id     = aws_vpc.vpn_test.id
  cidr_block = element(local.subnet_cidrs, count.index)

  tags = {
    Name  = "vpn-test-subnet-${count.index}"
    Stage = "dev"
  }
}

resource "aws_route_table" "vpn_test" {
  vpc_id = aws_vpc.vpn_test.id

  route {
    cidr_block = aws_vpc.vpn_test.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name  = "vpn-test-route-table"
    Stage = "dev"
  }
}

resource "aws_security_group" "vpn_test" {
  name        = "allow-all"
  description = "Allow all traffic just test in private VPC"
  vpc_id      = aws_vpc.vpn_test.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # AWS는 SG 생성 시 기본적으로 egress는 전체 허용이지만, Terraform은 기본 규칙 값이 없기 때문에 반드시 추가
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "vpn-test-sg"
    Stage = "dev"
  }
}

resource "aws_instance" "vpn_test" {
  count         = 2
  ami           = local.instance_info.ami_id
  instance_type = local.instance_info.instance_type

  subnet_id              = element(aws_subnet.vpn_test.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.vpn_test.id]
  key_name               = data.aws_key_pair.vpn_test.key_name

  tags = {
    Name  = "vpn-test-instance-${count.index}"
    Stage = "dev"
  }
}
