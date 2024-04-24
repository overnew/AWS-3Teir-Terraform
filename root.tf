
terraform  {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}




module "vpc" {
  source = "./vpc"

 project_name = var.project_name
 owner = var.project_name
 part =  "vpc"

 vpc_name = var.vpc_name
 vpc_cidr_block = var.vpc_cidr_block
 nat_gw_name = var.nat_gw_name

 igw_name = var.igw_name

 default_tag = {
    project = var.project_name
    owner = var.owner
    part = "vpc"
  }

  nat_eip_name = var.nat_eip_name
  public_subnet_data = var.public_subnet_data
  public_subnet_name = var.public_subnet_name
  public_rt_name = var.public_rt_name
  private_rt_name = var.private_rt_name

  private_subnet_data = var.private_subnet_data
  private_subnet_name = var.private_subnet_name
 
 /*
 az_1 = var.az_1
 az_2 = var.az_2

 web-subnet1-cidr = var.web-subnet1-cidr
 web-subnet1-name = var.web-subnet1-name

 
 web-subnet2-cidr = var.web-subnet2-cidr
 web-subnet2-name = var.web-subnet2-name

 app-subnet1-cidr = var.app-subnet1-cidr
 app-subnet1-name = var.app-subnet1-name
 app-subnet2-cidr = var.app-subnet2-cidr
 app-subnet2-name = var.app-subnet2-name

 db-subnet1-cidr = var.db-subnet1-cidr
 db-subnet1-name = var.db-subnet1-name
 db-subnet2-cidr = var.db-subnet2-cidr
 db-subnet2-name = var.db-subnet2-name
 
 public-rt-name = var.public-rt-name
 private-rt-name = var.private-rt-name*/
}

/*

#web security group#

resource "aws_security_group" "alb-web-sg" {
  name        = var.alb-sg-web-name
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb-sg-web-name
  }
}

#app security group#

resource "aws_security_group" "alb-app-sg" {
  name        = var.alb-sg-app-name
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web-asg-security-group.id]
    
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb-sg-app-name
  }
}

#database security group#

resource "aws_security_group" "db-sg" {
  name        = var.db-sg-name
  description = "DataBase Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {

    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app-asg-security-group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.db-sg-name
  }
}

#web load balancer#

resource "aws_lb" "web-alb" {
  name               = var.alb-web-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-web-sg.id]
  subnets            = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]
}

#app load balancer#

resource "aws_lb" "app-alb" {
  name               = var.alb-app-name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-app-sg.id]
  subnets            = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]

}



#web auto scaling group#

resource "aws_autoscaling_group" "web-asg" {
  name =   var.asg-web-name
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  target_group_arns   = [aws_lb_target_group.web-target-group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]

  launch_template {
    id      = aws_launch_template.web-launch-template.id
    version = aws_launch_template.web-launch-template.latest_version
  }

  tag {
    key                 = "webasgKey"
    value               = "webasgValue"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }
}

#web auto scaling security group#

resource "aws_security_group" "web-asg-security-group" {
  name        = var.asg-sg-web-name
  description = "ASG Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description = "HTTP from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb-web-sg.id]
  }


    ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg-sg-web-name
  }
}

#app auto scaling group#

resource "aws_autoscaling_group" "app-asg" {
  name =   var.asg-app-name
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  target_group_arns   = [aws_lb_target_group.app-target-group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]

  launch_template {
    id      = aws_launch_template.app-launch-template.id
    version = aws_launch_template.app-launch-template.latest_version
  }

  tag {
    key                 = "appasgKey"
    value               = "appasgValue"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }
}


#app auto scaling security group#

resource "aws_security_group" "app-asg-security-group" {
  name        = var.asg-sg-app-name
  description = "ASG Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description = "HTTP from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb-app-sg.id]
  }

    ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.web-asg-security-group.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg-sg-app-name
  }
}


#web launch template#

resource "aws_launch_template" "web-launch-template" {
  name          = var.launch-template-web-name
  image_id      = var.image-id
  instance_type = var.instance-type
  key_name      = var.key-name
  user_data     = filebase64("${path.module}/web_userdata.sh")

network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.web-asg-security-group.id]
  }

tag_specifications {

    resource_type = "instance"
    tags = {
      Name = var.launch-template-web-name
    }
  }
}

#app launch template#
# 여기서 WAS 동작용 코드를를 넣어줘야 한다.
resource "aws_launch_template" "app-launch-template" {
  name          = var.launch-template-app-name
  image_id      = var.image-id
  instance_type = var.instance-type
  key_name      = var.key-name
  user_data     = filebase64("${path.module}/app_userdata.sh")

  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.app-asg-security-group.id]
  }

  tag_specifications {

    resource_type = "instance"
    tags = {
      Name = var.launch-template-app-name
    }
  }
  
} 

#web target group#

resource "aws_lb_target_group" "web-target-group" {
  name     = "tg-web-name"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_name.id
  health_check {
    path = "/"
    matcher = 200
  }

}

resource "aws_lb_listener" "my_web_alb_listener" {
 load_balancer_arn = aws_lb.web-alb.arn 
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.web-target-group.arn
 }
}

#app target group#

resource "aws_lb_target_group" "app-target-group" {
  name     = "tg-app-name"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_name.id
  health_check {
    path = "/"
    matcher = 200
  }
}

resource "aws_lb_listener" "my_app_alb_listener" {
 load_balancer_arn = aws_lb.app-alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.app-target-group.arn
 }
}

#database instance#

resource "aws_db_instance" "database" {
  allocated_storage    = 10
  db_name              = var.db-name
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.instance-type-db
  username             = var.db-username
  password             = var.db-password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi_az = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.database-subnet-group.name
}


*/