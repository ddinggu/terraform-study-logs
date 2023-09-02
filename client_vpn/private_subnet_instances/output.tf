output "private_subnet_ids" {
  value = aws_subnet.vpn_test.*.id
}

output "private_subnet_cidrs" {
  value = aws_subnet.vpn_test.*.cidr_block
}

output "vpc_cidr" {
  value = aws_vpc.vpn_test.cidr_block
}
