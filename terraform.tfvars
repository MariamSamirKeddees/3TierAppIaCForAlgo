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
      { from_port = 80, to_port = 80, protocol = "tcp", sg_sources = ["lb_sg"] }
    ]
    egress = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }

  mariam-be_sg-IaC = {
    ingress = [
      { from_port = 8080, to_port = 8080, protocol = "tcp", sg_sources = ["interface_sg"] }
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
