output "private_rt_nat_ids" {
  value = { for az, rt in aws_route_table.private_rt_nat : az => rt.id }
}
