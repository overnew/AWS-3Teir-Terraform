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



# fix
/*
az_1 = "ap-northeast-1a"
az_2 = "ap-northeast-1c"

web-subnet1-cidr = "10.0.1.0/24"
web-subnet1-name = "3-tier-web-subnet-1"
web-subnet2-cidr = "10.0.2.0/24"
web-subnet2-name = "3-tier-web-subnet-2"

app-subnet1-cidr = "10.0.3.0/24"
app-subnet1-name = "3-tier-app-subnet-1"
app-subnet2-cidr = "10.0.4.0/24"
app-subnet2-name = "3-tier-app-subnet-2"

db-subnet1-cidr = "10.0.5.0/24"
db-subnet1-name = "3-tier-db-subnet-1"
db-subnet2-cidr = "10.0.6.0/24"
db-subnet2-name = "3-tier-db-subnet-2"


key-name = "3tier-key"

image-id = "ami-09a7535106fbd42d5"  #최신 우분투 AMI
instance-type = "t2.micro"
instance-type-db = "db.t3.micro"

launch-template-web-name = "3-tier-web-launch-template"
alb-web-name = "3-tier-web-alb"
alb-sg-web-name = "3-tier-web-alb-sg"
asg-web-name = "3-tier-web-asg"
asg-sg-web-name = "3-tier-web-asg-sg"
tg-web-name = "3-tier-web-tg"

launch-template-app-name = "3-tier-app-launch-template"
alb-app-name = "3-tier-app-alb"
alb-sg-app-name = "3-tier-app-alb-sg"
asg-app-name = "3-tier-app-asg"
asg-sg-app-name = "3-tier-app-asg-sg"
tg-app-name = "3-tier-app-tg"

db-name = "rdsdb"
db-sg-name = "3-tier-db-sg"
db-subnet-grp-name = "three-tier-db-subnet-group"
db-password = "rootroot"
db-username = "rootroot"
*/