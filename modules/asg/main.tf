data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-IaC"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.fe_sg_id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install nginx -y
    systemctl enable nginx
    systemctl start nginx
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.name}-instance"
    })
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.fe_sg_id]
  }

}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-IaC"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.fe_subnet_ids
  health_check_type         = "EC2"
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  target_group_arns = var.target_group_arns

  tag {
    key                 = "Name"
    value               = "${var.name}-IaC"
    propagate_at_launch = true
  }
}
