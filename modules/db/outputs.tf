output "db_subnet_ids" {
  value = var.db_subnet_ids
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "db_instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "db_host" {
  value = aws_db_instance.this.address
}