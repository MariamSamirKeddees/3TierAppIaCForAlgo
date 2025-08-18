resource "aws_db_subnet_group" "this" {
  name       = "${var.db_prefix_name}-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.db_prefix_name}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier              = var.db_prefix_name
  engine                  = "mysql"
  engine_version          = "8.0.43"
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = "gp2"
  username                = var.db_username
  password                = random_password.db_password.result
  db_name                 = var.db_name
  port                    = 3306
  multi_az                = var.multi_az
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.db_sg_id]
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name = var.db_prefix_name
  }

  depends_on = [aws_db_subnet_group.this]
}


