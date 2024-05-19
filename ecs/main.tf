#cluster

locals {
  cluster_name = "web-serivce-ecs"
  web_name = "web-server"
  app_name = "app-server"
}

#cluster
resource "aws_ecs_cluster" "web_service" {
  name = local.cluster_name

  setting {   # 컨테이너 지표 감시 가능
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    {
      Name = format("%s-%s",local.cluster_name ,"Cluster")
    },
    var.default_tag
  )
}

resource "aws_ecs_task_definition" "web_task" {
  family = "service"
  requires_compatibilities = ["FARGATE"]
  cpu                                 = "256"
  memory                              = "512"
  network_mode             = "awsvpc"

  #definition은 파일로 만들 수 있음 file("task-definitions/service.json")
  container_definitions = jsonencode([
    {
      name      = "first"
    #image 주소
      image     = "public.ecr.aws/nginx/nginx:1.26-alpine-perl" 
      #"851725230407.dkr.ecr.ap-northeast-1.amazonaws.com/name:apache" 
      #cpu       = 10
      #memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration: {
        logDriver: "awslogs",
        options: {
          awslogs-group: "/ecs/service",
          awslogs-region: "ap-northeast-1",
          awslogs-stream-prefix: "ecs-webserver"
          awslogs-create-group : "true"
        }
      }

      "healthCheck"  : {
          "command"     : [ "CMD-SHELL", "curl -f http://localhost:80/ || exit 1" ],
          "interval"    : 30,
          "timeout"     : 5,
          "startPeriod" : 10,
          "retries"     :3
        }

    } /*,
    {
      name      = "second"
      image     = "public.ecr.aws/nginx/nginx:1.26-alpine-perl"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }*/
  ])

  #볼륨
  #volume {  
  #  name      = "service-storage"
  #  host_path = "/ecs/service-storage"
  #}
  /*
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }*/

  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_role.arn

  tags = merge(
    {
      Name = format("%s-%s",local.web_name ,"task") 
    },
    var.default_tag
  )
}

resource "aws_ecs_service" "web_service" {
  name            = local.web_name
  cluster         = aws_ecs_cluster.web_service.id
  task_definition = aws_ecs_task_definition.web_task.arn
  desired_count   = 2
  launch_type                         = "FARGATE"
  scheduling_strategy                 = "REPLICA"
  #iam_role        = aws_iam_role.foo.arn awsvpc network mode면 자동 생성인듯
  #depends_on      = [aws_iam_role_policy.foo]

  # replace 전략
  #ordered_placement_strategy {
  #  type  = "binpack"
  #  field = "cpu"
  #}
    deployment_controller {
    type = "CODE_DEPLOY"
  }
  
  network_configuration {
    subnets           = [var.web_subnet_ids[0],var.web_subnet_ids[1]]
    assign_public_ip  = false
    security_groups   = [var.web_alb_sg_id]
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.web_target_group.arn
    container_name   = "first"
    container_port   = 80
  }
  depends_on  = [aws_lb_listener.web_listener]

  #placement_constraints {
  #  type       = "memberOf"
  #  expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #}
}

/*
#ecs task auto scaling
resource "aws_appautoscaling_target" "ecs_web_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.web_service.name}/${aws_ecs_service.web_service.name}" 
  #"service/${var.cluster_name}/${var.name_ecs_service}"

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_web_scale_out" {
  
  name               = "${local.web_name}-auto-scaling-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_web_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_web_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_web_target.service_namespace

  #StepScaling
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"

    #cooldown은 스케일링 후 다음 스케일링까지의 유예 시간
    cooldown                = 3

    #Average가 default
    metric_aggregation_type = "Average" #"Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      #metric_interval_upper_bound = 60

      #scaling 개수, 음 or 양
      scaling_adjustment          = 1
    }
  }

  depends_on = [ aws_appautoscaling_target.ecs_web_target ]
}


# scaling out 알람
resource "aws_cloudwatch_metric_alarm" "outscaling_metric_alarm" {
  
  alarm_name          = "${local.web_name}-outscaling-metric-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.web_service.name}"
    ServiceName = "${aws_ecs_service.web_service.name}"
  }

  #이 알람이 scaling policy을 트리거한다.
  alarm_actions = ["${aws_appautoscaling_policy.ecs_web_scale_out.arn}"]
}


resource "aws_appautoscaling_policy" "ecs_web_scale_in" {
  
  name               = "${local.web_name}-auto-scaling-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_web_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_web_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_web_target.service_namespace

  #StepScaling
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"

    #cooldown은 스케일링 후 다음 스케일링까지의 유예 시간
    cooldown                = 3

    #Average가 default
    metric_aggregation_type = "Average" #"Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      #metric_interval_upper_bound = 60

      #scaling 개수, 음 or 양
      scaling_adjustment          = -1
    }
  }

  depends_on = [ aws_appautoscaling_target.ecs_web_target ]
}

# scaling in 알람
resource "aws_cloudwatch_metric_alarm" "inscaling_metric_alarm" {
  
  alarm_name          = "${local.web_name}-inscaling-metric-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"  # 임계치보다 낮은 경우 트리거
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "30"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.web_service.name}"
    ServiceName = "${aws_ecs_service.web_service.name}"
  }

  #이 알람이 scaling policy을 트리거한다.
  alarm_actions = ["${aws_appautoscaling_policy.ecs_web_scale_in.arn}"]
}
*/

resource "aws_ecs_task_definition" "app_task" {
  family = "service"
  requires_compatibilities = ["FARGATE"]
  cpu                                 = "256"
  memory                              = "512"
  network_mode             = "awsvpc"

  #definition은 파일로 만들 수 있음 file("task-definitions/service.json")
  container_definitions = jsonencode([
    {
      name      = "app"
    #image 주소
      image     = "public.ecr.aws/nginx/nginx:1.26-alpine-perl" #"public.ecr.aws/lts/apache2:2.4-20.04_beta" 
      #cpu       = 10
      #memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      "healthCheck"  : {
          "command"     : [ "CMD-SHELL", "curl -f http://localhost:80/ || exit 1" ],
          "interval"    : 30,
          "timeout"     : 5,
          "startPeriod" : 10,
          "retries"     :3
      }

    }
  ])

  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_role.arn
  tags = merge(
    {
      Name = format("%s-%s",local.app_name ,"task") 
    },
    var.default_tag
  )
}

resource "aws_ecs_service" "app_service" {
  name            = local.app_name
  cluster         = aws_ecs_cluster.web_service.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 2
  launch_type                         = "FARGATE"
  scheduling_strategy                 = "REPLICA"
  
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets           = [var.app_subnet_ids[0], var.app_subnet_ids[1]]
    assign_public_ip  = false
    security_groups   = [var.web_alb_sg_id]  #일단 web sg로
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    container_name   = "app"
    container_port   = 80
  }
  depends_on  = [aws_lb_listener.web_listener]

}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })
  

  inline_policy {
    name = "task-role"
    
    policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogGroup",   #로그 그룹도 생성할 수 있도록 수정
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        }
    ]
    })
  }

  tags = var.default_tag
}

resource "aws_iam_policy" "ecs-policy" {
  name = "ldj-ecs-serive-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListAllMyBuckets", "s3:ListBucket", "s3:HeadBucket"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = var.default_tag
}