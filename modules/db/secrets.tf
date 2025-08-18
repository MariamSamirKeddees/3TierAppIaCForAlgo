resource "random_password" "db_password" {
  length  = 16
  special = false
}

#resource "random_string" "db_username" {
#  length  = 8
#  upper   = false
#  special = false
#}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "mariam-db-credentials-IaC"
  description = "Credentials and connection info for RDS MySQL database"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    host     = aws_db_instance.this.address        # <-- This will come from the RDS output later
    port     = 3306
    username = var.db_username
    password = random_password.db_password.result
    dbname   = var.db_name
  })
}
