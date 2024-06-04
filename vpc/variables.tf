variable "project_name" {
  description = "project name"
}

variable "owner" {
  description = "owner name"
}

variable "part" {
  description = "module's part"
}


variable "region" {}

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

variable "nat_eip_name" {}
variable "public_subnet_data" {}
variable "public_subnet_name" {}
variable "nfw_subnet_data" {}

variable "public_rt_name" {}
variable "private_rt_name" {}


variable "private_subnet_data" {}
variable "private_subnet_name" {}
variable "default_tag" {
  
}

variable "endpoint_sg_id" {
  description = "vpc interface endpoint" 
}

variable "log_central_bucket_arn" {}
variable "log_central_bucket" {}
variable "slack_alerts" {}