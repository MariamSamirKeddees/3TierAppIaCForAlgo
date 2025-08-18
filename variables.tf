 variable "vpc_cidr" {
  type        = string
}
variable "public_subnets" {
  type        = list(string)
}

variable "private_subnets" {
  type        = list(string)
}

variable "azs" {
  type = list(string)
}

variable "security_groups" {
  type = map(object({
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), [])
      sg_sources  = optional(list(string), [])
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "fe_subnet_ids" {
  type = list(string)
}

variable "fe_sg_id" {
  type = string
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "key_name" {
  type = string
}

variable "name" {
  type = string
}

#variable "nat_gateway_ids" {
#  type = list(string)
#}

variable "be_subnet_ids"{
  type = list(string)
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_prefix_name" {
  type        = string
}

variable "db_name" {
  type        = string
}

#variable "db_host" {
#  type        = string
#}

variable "instance_class" {}
variable "allocated_storage" {}
variable "multi_az" {
  type    = bool
  default = false
}

variable "db_sg_id" {
  type = string
}

variable "db_username" {
  type = string
}