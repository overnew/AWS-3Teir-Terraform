variable "project_name" {
  description = "project name"
}

variable "owner" {
  description = "owner name"
}

variable "part" {
  description = "module's part"
}




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

variable "public_rt_name" {}
variable "private_rt_name" {}


variable "private_subnet_data" {}
variable "private_subnet_name" {}
variable "default_tag" {
  
}
/*
variable "instance-type" {
  description = "ec2 Instance type"
}

variable "az_1" {
    description = "availability zone 1"
}

variable "az_2" {
    description = "availability zone 2"
}



variable "web-subnet1-cidr" {
  description = "CIDR Block for Web-tier Subnet-1"
}

variable "web-subnet1-name" {
  description = "Name for Web-tier Subnet-1"
}

variable "web-subnet2-cidr" {
  description = "CIDR Block for Web-tier Subnet-2"
}

variable "web-subnet2-name" {
  description = "Name for Web-tier Subnet-2"
}

variable "app-subnet1-cidr" {
  description = "CIDR Block for Application-tier Subnet-1"
}

variable "app-subnet1-name" {
  description = "Name for app-tier Subnet-1"
}

variable "app-subnet2-cidr" {
  description = "CIDR Block for Application-tier Subnet-2"
}

variable "app-subnet2-name" {
  description = "Name for Application-tier Subnet-2"
}


variable "db-subnet1-cidr" {
  description = "CIDR Block for Database-tier Subnet-1"
}

variable "db-subnet1-name" {
  description = "Name for Database-tier Subnet-1"
}

variable "db-subnet2-cidr" {
  description = "CIDR Block for Database-tier Subnet-2"
}

variable "db-subnet2-name" {
  description = "Name for Database-tier Subnet-2"
}

variable "public-rt-name" {
  description = "Name for Public Route table"
}

variable "private-rt-name" {
  description = "Name for Private Route table"
}
*/