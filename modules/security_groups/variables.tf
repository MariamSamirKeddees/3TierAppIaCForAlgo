variable "security_groups" {
  type = map(object({
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      sg_sources  = optional(list(string))
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      ipv6_cidr_blocks = optional(list(string))
      security_groups = optional(list(string))
    }))
  }))
}



#  mariam-alb_sg-IaC = { <= that's sg_name
#     sg_data includes ingress,egress rules
#    ingress = [ 
#      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
#      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
#    ]
#    egress = [
#      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
#    ]
#  }

#  mariam-fe_sg-IaC = {
#    ingress = [
#      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
#      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
#    ]
#    egress = [
#      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
#    ]
#  }

#resource "aws_security_group" "sg" {
#  for_each   = var.security_groups
#  name       = each.key
#  description = each.value.description
#  vpc_id     = var.vpc_id
#}

variable "vpc_id" {
  type        = string
} 