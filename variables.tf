variable "subnets" {
  type = map(object({
    cidr_block = string
    az         = string
  }))
}

