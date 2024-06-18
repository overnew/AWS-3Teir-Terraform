variable "vpc_id" {
  description = "vpc의 id를 변수로 받아옴"
}

variable "default_tag" {}
variable "part" {}

variable "vpc_cidr_block" {}

variable "web_alb_sg_name" {}
variable "web_security_group_name" {}
variable "app_security_group_name" {}