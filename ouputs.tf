output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.db.db_instance_endpoint
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.db.db_instance_id
}

output "db_host" {
  description = "RDS host address"
  value       = module.db.db_host
}
