output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
output "fe_tg_arn" {
  value = aws_lb_target_group.fe_tg.arn
}


output "be_tg_arn" {
  value       = aws_lb_target_group.be_tg.arn
}

output "listener_arn"{
  value = aws_lb_listener.http.arn
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}

output "fe_target_group_arn" {
  value = aws_lb_target_group.fe_tg.arn
}

output "be_target_group_arn" {
  value = aws_lb_target_group.be_tg.arn
}

