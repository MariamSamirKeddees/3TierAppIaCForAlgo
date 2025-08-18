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