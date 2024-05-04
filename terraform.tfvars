project_name = "again"
owner = "ldj"

#기본 태그 정보 정의


#VPC
region = "ap-northeast-1"
vpc_name = "3-tier-vpc"
vpc_cidr_block = "10.10.0.0/16"
igw_name = "3-tier-igw"
nat_gw_name = "nat-gw"

az_names = [
  "ap-northeast-1a",
  "ap-northeast-1c"
]

public_subnet_data = {
  pub_sub_1a = {
    zone = "ap-northeast-1a"
    cidr = "10.10.1.0/24"
  },
  pub_sub_2c = {
    zone = "ap-northeast-1c"
    cidr = "10.10.2.0/24"
  }
}

public_subnet_name = "public-subnet"
nat_eip_name = "nat-eip"
public_rt_name = "public-rt"
private_rt_name = "private-rt"


private_subnet_data = {
  web_sub_1a = {
    zone = "ap-northeast-1a"
    cidr = "10.10.16.0/20"
  },
  web_sub_2c = {
    zone = "ap-northeast-1c"
    cidr = "10.10.32.0/20"
  },
  app_sub_1a = {
    zone = "ap-northeast-1a"
    cidr = "10.10.48.0/20"
  },
  app_sub_2c = {
    zone = "ap-northeast-1c"
    cidr = "10.10.64.0/20"
  },
  db_sub_1a = {
    zone = "ap-northeast-1a"
    cidr = "10.10.80.0/20"
  },
  db_sub_2c = {
    zone = "ap-northeast-1c"
    cidr = "10.10.96.0/20"
  }
}
private_subnet_name = "public-subnet"



#Security Group
web_alb_sg_name = "web_alb_sg"
app_alb_sg_name = "app_alb_sg"

web_asg_security_group_name = "web_asg_security_group"
app_asg_security_group_name = "app_asg_security_group"
db_sg_name = "db_sg"

#3Tier
web_alb_name = "web-alb"
app_alb_name = "app-alb"
web_asg_name = "web-asg"
app_asg_name = "app-asg"
web_launch_template_name = "web-launch-template"
app_launch_template_name = "app-launch-template"
image_id = "ami-09a7535106fbd42d5"  #최신 우분투 AMI
instance_type = "t2.micro"
db_name = "3tier-db"
instance_type_db = "db.t3.micro"
db_username = "rootroot"
db_password = "rootroot"
db_subnet_group_name = "db-subnet-group"
