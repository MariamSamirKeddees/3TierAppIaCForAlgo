output "nat_gateway_ids" {
  value = { for az, _ in zipmap(var.azs, var.public_subnet_ids) : az => aws_nat_gateway.nat[az].id }
}
