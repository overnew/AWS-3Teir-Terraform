#web load balancer#

resource "aws_lb" "web_alb" {
  name               = var.web_alb_name
  #외부에서 접근 가능하게
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_alb_sg_id]
  subnets            = [var.public_subnet_ids[0], var.public_subnet_ids[1]]

  tags = merge(
    {
      Name = var.web_alb_name
    },
    var.default_tag
  )  
}

#app load balancer#

resource "aws_lb" "app_alb" {
  name               = var.app_alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.app_alb_sg_id]
  subnets            = [var.web_subnet_ids[0], var.web_subnet_ids[1]]
  tags = merge(
    {
      Name = var.app_alb_name
    },
    var.default_tag
  ) 
}

#web auto scaling group#

resource "aws_autoscaling_group" "web_asg" {
  name =   var.web_asg_name
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  target_group_arns   = [aws_lb_target_group.web_target_group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = var.web_subnet_ids

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = aws_launch_template.web_launch_template.latest_version
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

resource "aws_autoscaling_group" "app_asg" {
  name =   var.app_asg_name
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  target_group_arns   = [aws_lb_target_group.app_target_group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = var.app_subnet_ids

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = aws_launch_template.app_launch_template.latest_version
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


#web launch template#

resource "aws_launch_template" "web_launch_template" {
  name          = var.web_launch_template_name
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = filebase64("${path.module}/userdata/web_userdata.sh")

  network_interfaces {
    device_index    = 0
    security_groups = [var.web_alb_sg_id]
  }

  tag_specifications {

    resource_type = "instance"
    tags = merge(
    {
      Name = var.web_launch_template_name
    },
    var.default_tag
  ) 
  }
}

#app launch template#
# 여기서 WAS 동작용 코드를를 넣어줘야 한다.
resource "aws_launch_template" "app_launch_template" {
  name          = var.app_launch_template_name
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = filebase64("${path.module}/userdata/app_userdata.sh")

  network_interfaces {
    device_index    = 0
    security_groups = [var.app_asg_security_group_id]
  }

  tag_specifications {

    resource_type = "instance"
    tags = merge(
    {
      Name = var.app_launch_template_name
    },
    var.default_tag
  ) 
  }
  
} 

#web target group#

resource "aws_lb_target_group" "web_target_group" {
  name     = "tg-web-name"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/"
    matcher = 200
  }
}

resource "aws_lb_listener" "my_web_alb_listener" {
 load_balancer_arn = aws_lb.web_alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.web_target_group.arn
 }
}

#app target group#

resource "aws_lb_target_group" "app_target_group" {
  name     = "tg-app-name"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/"
    matcher = 200
  }
}

resource "aws_lb_listener" "my_app_alb_listener" {
 load_balancer_arn = aws_lb.app_alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.app_target_group.arn
 }
}

#database instance#
/*
resource "aws_db_instance" "database" {
  allocated_storage    = 10
  db_name              = var.db_name
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.instance_type_db
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi_az = true
  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name
  tags = merge(
    {
      Name = var.db_name
    },
    var.default_tag
  ) 
}


#database subnet group#
resource "aws_db_subnet_group" "database_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids
 tags = merge(
    {
      Name = var.db_subnet_group_name
    },
    var.default_tag
  ) 
}
*/