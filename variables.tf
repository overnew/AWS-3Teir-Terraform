variable "project_name" {
  description = "project name"
}

variable "owner" {
  description = "resource creator"
}

variable "user_id" {}


variable "region" {
  description = "aws_region"
}

variable "s3_backup_tag" {
  
}

variable "SLACK_WEBHOOK_URL" {}

variable "vpc_name" {
    description = "vpc name"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
}

variable "nat_gw_name" {
  description = "NAT Gateway name"
}

variable "igw_name" {
  description = "internet gateway name"
  
}

variable "az_names" {}
variable "public_subnet_data" {}
variable "nfw_subnet_data" {}
variable "public_subnet_name" {}
variable "nat_eip_name" {}
variable "public_rt_name" {}
variable "private_rt_name" {}


variable "private_subnet_data" {}
variable "private_subnet_name" {}


#보안 그룹
variable "web_alb_sg_name" {}
variable "web_security_group_name" {}
variable "app_security_group_name" {}
variable "db_sg_name" {}

#3Tier
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



#vpc endpoint part

variable "secretsmanager_vpc_endpoint_sg_name" {}
variable "secretsmanager_endpoint_name" {}
