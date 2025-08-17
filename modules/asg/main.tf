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

#  user_data = base64encode(<<-EOF
#    #!/bin/bash  
#    exec > /var/log/user-data.log 2>&1
#    set -x
#    sudo snap install amazon-ssm-agent --classic
#    sudo systemctl enable amazon-ssm-agent
#    sudo systemctl start amazon-ssm-agent
#
#    sudo apt-get update -y
#    sudo apt-get install nginx -y
#    systemctl enable nginx
#    systemctl start nginx
#EOF
#  )

  user_data = base64encode(<<-EOF
  #!/bin/bash
  exec > /var/log/user-data.log 2>&1
  set -x
  sleep 30
  cloud-init status --wait
  apt-get update -y
  apt-get install -y nginx
  systemctl enable nginx
  systemctl start nginx
  snap install amazon-ssm-agent --classic
  systemctl enable amazon-ssm-agent
  systemctl start amazon-ssm-agent
EOF
)


  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.name}-instance"
    })
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }

}

resource "aws_iam_role" "ssm" {
  name = "mariam-ssm-role-IaC"#
 assume_role_policy = jsonencode({
   Version = "2012-10-17",
   Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
     Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "mariam-ssm-profile-IaC"
  role = aws_iam_role.ssm.name
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

