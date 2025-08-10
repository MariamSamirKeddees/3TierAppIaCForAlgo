variable "public_subnets" {
  type        = list(string)
}

variable "private_subnets" {
  type        = list(string)
}

variable "vpc_id" {
  type        = string
}

variable "azs" {
  type = list(string)
}