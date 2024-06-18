locals {
#  public_sg  = format("%s-%s-sg", var.name, "public")
#  private_sg = format("%s-%s-sg", var.name, "private")
  endpoint_sg_name = "endpoint-${var.part}"
}


resource "aws_security_group" "web_alb_sg" {
  name        = var.web_alb_sg_name
  description = "Interfacing ALB Security Group"
  vpc_id      = var.vpc_id

  /* HTTPS로만 통신
  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }*/

  ingress {
    description = "https from internet"
    from_port   = 443
    to_port     = 443
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

#web security group#
resource "aws_security_group" "web_security_group" {
  name        = var.web_security_group_name
  description = "web ASG Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.web_security_group_name
    },
    var.default_tag
  )
}

resource "aws_security_group" "app_security_group" {
  name        = var.app_security_group_name
  description = "APP ASG Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.app_security_group_name
    },
    var.default_tag
  )
}


#Interface endpoint SG
resource "aws_security_group" "vpc_endpoint_sg" {
  name = local.endpoint_sg_name
  vpc_id = var.vpc_id

  #https 트래픽만 받음
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"

    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Internal outbound any traffic"
  }

  tags = merge(
    {
      Name = local.endpoint_sg_name
    },
    var.default_tag
  )  
}
