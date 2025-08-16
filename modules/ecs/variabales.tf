variable "name" {
  type        = string
}

variable "container_image" {
  type        = string
}

variable "be_subnet_ids" {
  type        = list(string)
}

variable "be_sg_id" {
  type        = string
}

variable "be_tg_arn" {
  type        = string
}
