resource "aws_alb" "application_load_balancer" {
  name                      = "test-alb"
  internal                  = false
  load_balancer_type        = "application"
  subnets                   = [var.public_subnet_ids[0], var.public_subnet_ids[1]]
  security_groups           = [var.web_alb_sg_id]

 tags = merge(
    {
      Name = "test-alb"
    },
    var.default_tag
  ) 
}

#Defining the target group and a health check on the application
resource "aws_lb_target_group" "target_group" {
  name                      = "test-tg"
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
}

#Defines an HTTP Listener for the ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn         = aws_alb.application_load_balancer.arn
  port                      = "80"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.target_group.arn
  }
}