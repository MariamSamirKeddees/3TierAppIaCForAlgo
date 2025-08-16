variable "azs" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "be_subnet_ids" {
  type = list(string)
}

variable "private_rt_nat_ids" {
  type        = map(string)
}
