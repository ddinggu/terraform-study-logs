data "aws_acm_certificate" "server" {
  domain   = "server"
  types    = ["IMPORTED"]
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "client" {
  domain   = "client1.domain.tld"
  types    = ["IMPORTED"]
  statuses = ["ISSUED"]
}
