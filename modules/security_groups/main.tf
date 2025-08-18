# -------------------------
# Step 1: Create empty SGs
# -------------------------
resource "aws_security_group" "sg" {
  for_each = var.security_groups
  name     = each.key
  vpc_id   = var.vpc_id

  tags = {
    Name = each.key
  }
}

# -------------------------
# Step 2: Add SG Rules
# -------------------------

# ALB inbound (public internet → ALB on 80 & 443)
resource "aws_security_group_rule" "alb_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sg["mariam-alb_sg-IaC"].id
}

resource "aws_security_group_rule" "alb_https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sg["mariam-alb_sg-IaC"].id
}

# FE inbound (only from ALB on 80, 443, and SSH if you want)
resource "aws_security_group_rule" "fe_http_in" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg["mariam-alb_sg-IaC"].id
  security_group_id        = aws_security_group.sg["mariam-fe_sg-IaC"].id
}

resource "aws_security_group_rule" "fe_https_in" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg["mariam-alb_sg-IaC"].id
  security_group_id        = aws_security_group.sg["mariam-fe_sg-IaC"].id
}

resource "aws_security_group_rule" "fe_ssh_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["41.35.193.91/32"] 
  security_group_id = aws_security_group.sg["mariam-fe_sg-IaC"].id
}

# BE inbound (only from FE on 8080)
resource "aws_security_group_rule" "be_app_in" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg["mariam-fe_sg-IaC"].id
  security_group_id        = aws_security_group.sg["mariam-be_sg-IaC"].id
}

# DB inbound (only from BE on 3306)
resource "aws_security_group_rule" "db_mysql_in" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg["mariam-be_sg-IaC"].id
  security_group_id        = aws_security_group.sg["mariam-db_sg-IaC"].id
}

# -------------------------
# Step 3: Egress (allow all)
# -------------------------
resource "aws_security_group_rule" "all_egress" {
  for_each = aws_security_group.sg

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = each.value.id
}
