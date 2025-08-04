resource "aws_vpc" "mariam-3tierApp-IaC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mariam-3tierApp-IaC"
  }
}

resource "aws_subnet" "mariam-subnets" { 
  for_each = var.subnets

  vpc_id     = aws_vpc.mariam-3tierApp-IaC.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "mariam-igw" {
  vpc_id = aws_vpc.mariam-3tierApp-IaC.id
  tags = {
    Name = "mariam-igw-IaC"
  }
}


resource "aws_route_table" "mariam-pub-rt" {
  vpc_id = aws_vpc.mariam-3tierApp-IaC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mariam-igw.id
  }
  tags = {
    Name = "mariam-pub-rt-IaC"
  }
}

resource "aws_route_table_association" "mariam-pub-rt-assoc" {
  for_each = {
    for key, subnet in var.subnets :
    key => aws_subnet.mariam-subnets[key].id
    if startswith(key, "mariam-pub")
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.mariam-pub-rt.id
}

resource "aws_eip" "mariam-eip" {
    for_each = {
    for key, subnet in var.subnets :
    key => subnet
    if startswith(key, "mariam-pub")
  }

  domain = "vpc"
    tags = {
  Name = "${each.key}-eip-IaC"
  }
}

resource "aws_nat_gateway" "mariam-nat" {
  for_each = aws_eip.mariam-eip
  allocation_id = aws_eip.mariam-eip[each.key].id
  
  subnet_id = aws_subnet.mariam-subnets[each.key].id

  tags = {
    Name = "${each.key}-nat-IaC"
  }

  depends_on = [ aws_internet_gateway.mariam-igw ]
}


resource "aws_route_table" "mariam-priv-rt" {
  for_each = aws_nat_gateway.mariam-nat 

  vpc_id = aws_vpc.mariam-3tierApp-IaC.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "mariam-priv-rt-${substr(each.key, -2, 2)}-IaC"
  }
}


resource "aws_route_table_association" "mariam-priv-rt-assoc" {
  for_each = {
    for key, subnet in aws_subnet.mariam-subnets :
    key => subnet.id if startswith(key, "mariam-priv")
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.mariam-priv-rt[local.priv_to_pub_map[each.key]].id 
}

resource "aws_security_group" "mariam-sg-alb" {
  name        = "alb-sg"
  description = "Allow HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.mariam-3tierApp-IaC.id

  tags = {
    Name = "mariam-sg-alb-IaC"
  }
}

resource "aws_vpc_security_group_ingress_rule" "port-443-inbound" {
  security_group_id = aws_security_group.mariam-sg-alb.id
  cidr_ipv4         = aws_vpc.mariam-3tierApp-IaC.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "port-80-inbound" {
  security_group_id = aws_security_group.mariam-sg-alb.id
  cidr_ipv4         = aws_vpc.mariam-3tierApp-IaC.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_security_group" "mariam-sg-fe" {
  name        = "fe-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.mariam-3tierApp-IaC.id

  tags = {
    Name = "mariam-sg-fe-IaC"
  }
}

resource "aws_security_group_rule" "alb-to-fe" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mariam-sg-alb.id
  security_group_id        = aws_security_group.mariam-sg-fe.id
  description              = "Allow HTTPS traffic from source_sg"
}

resource "aws_security_group" "mariam-sg-be" {
  name        = "be-sg"
  description = "Allow traffic from FE only"
  vpc_id      = aws_vpc.mariam-3tierApp-IaC.id

  tags = {
    Name = "mariam-sg-be-IaC"
  }
}

resource "aws_security_group_rule" "fe-to-be" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mariam-sg-fe.id
  security_group_id        = aws_security_group.mariam-sg-be.id
  description              = "Allow HTTPS traffic from source_sg"
}

resource "aws_security_group" "mariam-sg-db" {
  name        = "db-sg"
  description = "Allow traffic from BE only"
  vpc_id      = aws_vpc.mariam-3tierApp-IaC.id

  tags = {
    Name = "mariam-sg-db-IaC"
  }
}

resource "aws_security_group_rule" "be-to-db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mariam-sg-be.id
  security_group_id        = aws_security_group.mariam-sg-db.id
  description              = "Allow HTTPS traffic from source_sg"
}


locals {
   public-subnets = {
    for k, v in var.subnets : k => v if startswith(k, "mariam-pub")
  }
  
   public-subnet-resources = {
    for k, v in aws_subnet.mariam-subnets : k => v if startswith(k, "mariam-pub")
  }

  public-subnet-ids = [for s in local.public-subnet-resources : s.id]

  subnet_az_map = {
    for key, subnet in aws_subnet.mariam-subnets :
    key => substr(key, -2, 2)
  }
  
  # Create a simplified mapping from private to public subnets
  priv_to_pub_map = {
    for key, subnet in aws_subnet.mariam-subnets :
    key => "mariam-pub-${local.subnet_az_map[key]}"
    if startswith(key, "mariam-priv")
  }

  
}

resource "aws_lb" "mariam-alb" {
  name               = "mariam-alb-IaC"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mariam-sg-alb.id]
  subnets            = local.public-subnet-ids

  tags = {
    Name        = "mariam-alb-IaC"
  }
} 

resource "aws_lb_target_group" "mariam-tg" {
  name     = "mariam-tg-IaC"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mariam-3tierApp-IaC.id
  
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "mariam-tg-IaC"
  }
}

resource "aws_security_group" "mariam-sg-ec2" {
  name        = "mariam-sg-ec2"
  description = "Security group for EC2 instances in private subnets"
  vpc_id      = aws_vpc.mariam-3tierApp-IaC.id

  tags = {
    Name = "mariam-sg-ec2-IaC"
  }
}

# Allow HTTP traffic ONLY from the ALB security group
resource "aws_security_group_rule" "ec2_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mariam-sg-ec2.id
  source_security_group_id = aws_security_group.mariam-sg-alb.id  
}

# Allow SSH access only from your trusted IP (optional)
resource "aws_security_group_rule" "ec2_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.mariam-sg-ec2.id
  cidr_blocks       = ["41.65.170.97/32"]  # Replace with your public IP
}

# Allow all outbound traffic (common for EC2 instances)
resource "aws_security_group_rule" "ec2_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  
  security_group_id = aws_security_group.mariam-sg-ec2.id
  cidr_blocks       = ["0.0.0.0/0"]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # AMD64 = Standard x86
  }
}

resource "aws_key_pair" "mariam_key" {
  key_name   = "mariam-key"  
  public_key = file("~/.ssh/terraform-key.pub")  
}

resource "aws_launch_template" "mariam-launchtemp" {
  name          = "mariam-launchtemp-IaC"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.mariam_key.key_name
  
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.mariam-sg-ec2.id]
  }


  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Mariam's ASG</h1>" > /var/www/html/index.html
              EOF
             )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "mariam-ec2-IaC"
    }
  }
}

resource "aws_autoscaling_group" "mariam-asg" {
  name                = "mariam-asg-IaC"
  desired_capacity    = 2
  max_size            = 6
  min_size            = 2
  vpc_zone_identifier = [for k, v in aws_subnet.mariam-subnets : v.id if contains(["mariam-priv-fe-1a", "mariam-priv-fe-1b"], k)]
  
  target_group_arns = [aws_lb_target_group.mariam-tg.arn]

  launch_template {
    id      = aws_launch_template.mariam-launchtemp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "mariam-asg-IaC"
    propagate_at_launch = true
  }
}


