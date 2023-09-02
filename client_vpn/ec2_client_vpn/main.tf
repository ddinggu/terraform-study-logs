locals {
  private_subnet_ids   = var.private_subnet_ids
  private_subnet_cidrs = var.private_subnet_cidrs
  vpc_cidr             = var.vpc_cidr
  enable_log           = var.enable_log
  enable_banner        = var.enable_banner
}

resource "aws_ec2_client_vpn_endpoint" "vpn_test" {
  description            = "clientvpn-test"
  server_certificate_arn = data.aws_acm_certificate.server.arn
  client_cidr_block      = "192.168.0.0/16"
  session_timeout_hours  = 8
  transport_protocol     = "udp"
  vpn_port               = 443
  split_tunnel           = false # 분할 터널 활성화 여부(https://docs.aws.amazon.com/ko_kr/vpn/latest/clientvpn-admin/split-tunnel-vpn.html)

  # 클라이언트 인증방법인 상호인증, SSO, AD 방식 중 '상호인증' 방식 선택
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.client.arn
  }

  # (Required) 연결 로그 수집 여부 설정. 데이터는 Cloudwatch 로그 그룹에 수집됨
  connection_log_options {
    enabled               = local.enable_log
    cloudwatch_log_group  = local.enable_log ? aws_cloudwatch_log_group.vpn_test[0].name : null
    cloudwatch_log_stream = local.enable_log ? aws_cloudwatch_log_stream.vpn_test[0].name : null
  }

  # AWS Client VPN 프로그램으로 VPN Session 설정되었을 시 출력되는 배너 문구 설정
  client_login_banner_options {
    enabled     = local.enable_banner
    banner_text = local.enable_banner ? "Welcome Client VPN Connection!" : null
  }

  depends_on = [aws_cloudwatch_log_group.vpn_test[0], aws_cloudwatch_log_stream.vpn_test[0]]

  tags = {
    Stage = "dev"
  }
}

# VPN 연결 권한 부여 설정
# 상호인증 방식은 클라이언트 그룹화가 불가하여 연결 권한 세분화 불가함
resource "aws_ec2_client_vpn_authorization_rule" "vpn_test" {
  count = length(local.private_subnet_cidrs)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_test.id
  target_network_cidr    = element(local.private_subnet_cidrs, count.index)
  authorize_all_groups   = true
}

# VPN 엔드포인트와 연결될 서브넷 설정. 연결한 서브넷에 VPN Network Interface 생성
# 고가용성을 위해 2개 이상의 서브넷에 연결하는 것을 AWS 측에선 권장
resource "aws_ec2_client_vpn_network_association" "vpn_test" {
  count = length(local.private_subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_test.id
  subnet_id              = element(local.private_subnet_ids, count.index)
}

## VPN 엔드포인트의 라우팅 테이블 설정 방법
## 기본적으로 VPN-서브넷 네트워크 연결 시 VPC CIDR 대역에 대한 default 라우팅 테이블 설정되므로 커스텀이 필요할 시 사용
# resource "aws_ec2_client_vpn_route" "example" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.example.id
#   destination_cidr_block = "0.0.0.0/0"
#   target_vpc_subnet_id   = aws_ec2_client_vpn_network_association.example.subnet_id
# }
