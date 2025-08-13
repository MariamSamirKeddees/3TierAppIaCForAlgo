variable "name" {}
variable "instance_type" {}
variable "key_name" {}
variable "fe_sg_id" {}
variable "fe_subnet_ids" { type = list(string) }
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "target_group_arns" { type = list(string) }
variable "tags" { default = {} }
variable "ami_id" {}