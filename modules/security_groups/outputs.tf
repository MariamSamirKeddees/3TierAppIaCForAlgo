output "security_group_ids" {
  value = { for k, sg in aws_security_group.sg : k => sg.id }
}

output "be_sg_id" {
  value = aws_security_group.sg["mariam-be_sg-IaC"].id
}
