locals {
  alb_name = "web-service-alb"

  target_group_name = "target-group"
  web_target_group_name = format("%s-%s",local.web_name ,local.target_group_name) 
  app_target_group_name = format("%s-%s",local.app_name ,local.target_group_name) 
  
  listner_name = "listner"
  service_listener_name = format("%s-%s","service" ,local.listner_name) 
  test_listener_name = format("%s-%s","test" ,local.listner_name) 
}


resource "aws_alb" "web_alb" {
  name                      = local.alb_name
  internal                  = false
  load_balancer_type        = "application"
  subnets                   = [var.public_subnet_ids[0], var.public_subnet_ids[1]]
  security_groups           = [var.web_alb_sg_id]

 tags = merge(
    {
      Name = local.alb_name
    },
    var.default_tag
  ) 
}

#Defining the target group and a health check on the application
resource "aws_lb_target_group" "web_target_group" {
  name                      = local.web_target_group_name
  port                      = 80
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = var.vpc_id
  health_check {
      path                  = "/"
      protocol              = "HTTP"
      matcher               = "200"
      port                  = "traffic-port"
      healthy_threshold     = 2
      unhealthy_threshold   = 2
      timeout               = 10
      interval              = 30
  }

   tags = merge(
    {
      Name = local.web_target_group_name
    },
    var.default_tag
  ) 
}

#Defines an HTTP Listener for the ALB
resource "aws_lb_listener" "service_listener" {
  load_balancer_arn         = aws_alb.web_alb.arn
  port                      = "80"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.web_target_group.arn
  }

  tags = merge(
    {
      Name = local.service_listener_name
    },
    var.default_tag
  ) 
}


resource "aws_lb_listener_rule" "web_rule" {
  listener_arn = aws_lb_listener.service_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  #condition {
  #  host_header {
  #    values = ["example.com"]
  #  }
  #}
}



#Defining the target group and a health check on the application
resource "aws_lb_target_group" "app_target_group" {
  name                      = local.app_target_group_name 
  port                      = 80
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = var.vpc_id
  health_check {
      path                  = "/"
      protocol              = "HTTP"
      matcher               = "200"
      port                  = "traffic-port"
      healthy_threshold     = 2
      unhealthy_threshold   = 2
      timeout               = 10
      interval              = 30
  }

  tags = merge(
    {
      Name = local.app_target_group_name 
    },
    var.default_tag
  ) 
}


resource "aws_lb_listener_rule" "app_rule" {
  listener_arn = aws_lb_listener.service_listener.arn
  priority     = 90  #1에 가까울 수록 높은 우선순위

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/sign*","/my*"]
    }
  }

}



#deploy용 test 그룹
resource "aws_lb_listener" "test_listener" {
  load_balancer_arn         = aws_alb.web_alb.arn
  port                      = "8080"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    #target_group_arn        = aws_lb_target_group.web_test_target_group.arn
    target_group_arn        = aws_lb_target_group.web_target_group.arn  
  }

  tags = merge(
    {
      Name = local.service_listener_name
    },
    var.default_tag
  ) 
}

resource "aws_lb_target_group" "web_test_target_group" {
  name                      = "${local.web_target_group_name}-test"
  port                      = 80
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = var.vpc_id
  health_check {
      path                  = "/"
      protocol              = "HTTP"
      matcher               = "200"
      port                  = "traffic-port"
      healthy_threshold     = 2
      unhealthy_threshold   = 2
      timeout               = 10
      interval              = 30
  }

   tags = merge(
    {
      Name = "${local.web_target_group_name}-test"
    },
    var.default_tag
  ) 
}

resource "aws_lb_listener_rule" "web_test_rule" {
  listener_arn = aws_lb_listener.test_listener.arn
  priority     = 110

  action {
    type             = "forward"
    #target_group_arn = aws_lb_target_group.web_test_target_group.arn
    target_group_arn = aws_lb_target_group.web_test_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  #condition {
  #  host_header {
  #    values = ["example.com"]
  #  }
  #}
}


resource "aws_lb_target_group" "app_test_target_group" {
  name                      = "${local.app_target_group_name}-test"
  port                      = 80
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = var.vpc_id
  health_check {
      path                  = "/"
      protocol              = "HTTP"
      matcher               = "200"
      port                  = "traffic-port"
      healthy_threshold     = 2
      unhealthy_threshold   = 2
      timeout               = 10
      interval              = 30
  }

  tags = merge(
    {
      Name = "${local.app_target_group_name}-test"
    },
    var.default_tag
  ) 
}


resource "aws_lb_listener_rule" "app_test_rule" {
  listener_arn = aws_lb_listener.test_listener.arn
  priority     = 95  #1에 가까울 수록 높은 우선순위

  action {
    type             = "forward"
    #target_group_arn = aws_lb_target_group.app_test_target_group.arn
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/sign*","/my*"]
    }
  }

  #condition {
  #  host_header {
  #    values = ["example.com"]
  #  }
  #}
}
