output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
output "fe_tg_arn" {
  value = aws_lb_target_group.fe_tg.arn
}


output "be_tg_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.be_tg.arn
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}
