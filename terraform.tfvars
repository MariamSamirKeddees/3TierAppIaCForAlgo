vpc_cidr = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = [
  "10.0.3.0/24",
  "10.0.4.0/24",
  "10.0.5.0/24",
  "10.0.6.0/24",
  "10.0.7.0/24",
  "10.0.8.0/24"
]
azs = ["us-east-1a", "us-east-1b"]


security_groups = {
  mariam-alb_sg-IaC = {
    ingress = [
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ]
    egress = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]

  }

  mariam-fe_sg-IaC = {
    ingress = [
      { from_port = 80, to_port = 80, protocol = "tcp", sg_sources = ["lb_sg"] },
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["102.44.195.74/32"] }
    ]
    egress = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }

  mariam-be_sg-IaC = {
    ingress = [
      { from_port = 8080, to_port = 8080, protocol = "tcp", sg_sources = ["fe_sg"] }
    ]
    egress = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }

  mariam-db_sg-IaC = {
    ingress = [
      { from_port = 3306, to_port = 3306, protocol = "tcp", sg_sources = ["be_sg"] }
    ]
    egress = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
}



ami_id              = "ami-08c40ec9ead489470"
instance_type       = "t2.micro"
fe_subnet_ids       = ["subnet-062bb44675e1e9355", "subnet-0ddbe07a005dd277c"]
fe_sg_id            = "sg-01971f6910e79a0fc"
desired_capacity    = 2
min_size            = 1
max_size            = 4
key_name            = "mariam-ssh-3tier"
name                = "mariam-nginx-IaC"

be_subnet_ids       = ["subnet-082ca8d172401961a", "subnet-0b3b99ae42959fd86"]
