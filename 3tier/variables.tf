# SG 모듈에서 가져옴
variable "web_asg_security_group_id" {}
variable "app_asg_security_group_id" {}
variable "web_alb_sg_id" {}
variable "app_alb_sg_id" {}
variable "db_sg_id" {}

#vpc에서 subnet id가져오기
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}

variable "web_subnet_ids" {}
variable "app_subnet_ids" {}
variable "db_subnet_ids" {}

#3tier의 var
variable "web_alb_name" {}
variable "app_alb_name" {}
variable "web_asg_name" {}
variable "app_asg_name" {}
variable "web_launch_template_name" {}
variable "app_launch_template_name" {}


variable "image_id" {}
variable "instance_type" {}
variable "key_name" {}


variable "db_name" {}
variable "instance_type_db" {}
variable "db_username" {}
variable "db_password" {}
variable "db_subnet_group_name" {}

#태그
variable "default_tag" {}