#locals {
#  public_sg  = format("%s-%s-sg", var.name, "public")
#  private_sg = format("%s-%s-sg", var.name, "private")
#}


resource "aws_security_group" "web_alb_sg" {
  name        = var.web_alb_sg_name
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

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
  
  tags = merge(
    {
      Name = var.web_alb_sg_name
    },
    var.default_tag
  )
  
}


#app security group#
resource "aws_security_group" "app_alb_sg" {
  name        = var.app_alb_sg_name
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

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

  tags = merge(
    {
      Name = var.app_alb_sg_name
    },
    var.default_tag
  )
}

#web auto scaling security group#

resource "aws_security_group" "web_asg_security_group" {
  name        = var.web_asg_security_group_name
  description = "web ASG Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id]
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

  tags = merge(
    {
      Name = var.web_asg_security_group_name
    },
    var.default_tag
  )
}

resource "aws_security_group" "app_asg_security_group" {
  name        = var.app_asg_security_group_name
  description = "APP ASG Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.app_alb_sg.id]
  }

    ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.web_asg_security_group.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.app_asg_security_group_name
    },
    var.default_tag
  )
}

#database security group
resource "aws_security_group" "db_sg" {
  name        = var.db_sg_name
  description = "DataBase Security Group"
  vpc_id      = var.vpc_id

  ingress {

    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app_asg_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.db_sg_name
    },
    var.default_tag
  )
}
