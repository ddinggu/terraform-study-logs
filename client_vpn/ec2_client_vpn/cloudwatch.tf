resource "aws_cloudwatch_log_group" "vpn_test" {
  count = local.enable_log ? 1 : 0

  name              = "client-vpn-connection"
  retention_in_days = 30

  tags = {
    State = "dev"
  }
}

resource "aws_cloudwatch_log_stream" "vpn_test" {
  count = local.enable_log ? 1 : 0

  name           = "client-vpn-connection-log-stream"
  log_group_name = aws_cloudwatch_log_group.vpn_test[0].name
}
