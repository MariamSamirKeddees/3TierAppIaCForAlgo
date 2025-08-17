variable "vpc_id" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "igw_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "be_subnet_ids"{
  type = list(string)
}

variable "fe_subnet_ids"{
  type = list(string)
}

variable "az_to_public_subnet" {
  type = map(string)
}

variable "nat_gateway_ids" {
  type = map(string)
}
