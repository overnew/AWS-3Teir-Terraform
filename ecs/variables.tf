variable "default_tag" {}
variable "vpc_id" {
  description = "vpc의 id를 변수로 받아옴"
}

variable "public_subnet_ids" {}
variable "private_subnet_ids" {}

variable "web_subnet_ids" {}
variable "app_subnet_ids" {}


variable "web_alb_sg_id" {}
variable "web_security_group" {}
variable "app_security_group" {}


variable "slack_sns_arn" {}