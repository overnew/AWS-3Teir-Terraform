locals {
  app_cluster_name = "app-ecs"
  app_name = "app-service"
  app_service_family_name = "app-service"
}

#cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = local.app_cluster_name

  setting {   # 컨테이너 지표 감시 가능
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    {
      Name = format("%s-%s",local.app_cluster_name ,"cluster")
    },
    var.default_tag
  )
}


resource "aws_ecs_task_definition" "app_task" {
  family = local.app_service_family_name
  requires_compatibilities = ["FARGATE"]
  cpu                                 = "256"
  memory                              = "512"
  network_mode             = "awsvpc"

  #definition은 파일로 만들 수 있음 file("task-definitions/service.json")
  container_definitions = jsonencode([
    {
      name      = "app"
    #image 주소
      image     = "851725230407.dkr.ecr.ap-northeast-1.amazonaws.com/milliapp:appv02" #"public.ecr.aws/lts/apache2:2.4-20.04_beta" 
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
    ,{
            "name": "aws-otel-collector",
            "image": "public.ecr.aws/aws-observability/aws-otel-collector:v0.39.0",
            "cpu": 0,
            "portMappings": [],
            "essential": true,
            "environment": [
                {
                    "name": "AWS_PROMETHEUS_ENDPOINT",
                    "value": "https://aps-workspaces.ap-northeast-1.amazonaws.com/workspaces/ws-ddab0164-4917-44b4-9854-0abf2551f6a6/api/v1/remote_write"
                }
            ],
            "mountPoints": [],
            "volumesFrom": [],
            "secrets": [
                {
                    "name": "AOT_CONFIG_CONTENT",
                    "valueFrom": "otel-collector-config"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "/ecs/ecs-aws-otel-sidecar-collector",
                    "awslogs-region": "ap-northeast-1",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            },
            "systemControls": []
        }

  ]
  
  )

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
  cluster         = aws_ecs_cluster.app_cluster.arn
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
  depends_on  = [aws_lb_listener.service_listener]

}


#auto scaling
#### auto
#ecs task auto scaling
resource "aws_appautoscaling_target" "ecs_app_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.app_service.name}" 

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_app_scale_out" {
  
  name               = "${local.app_name}-auto-scaling-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_app_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_app_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_app_target.service_namespace

  #StepScaling
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"

    #cooldown은 스케일링 후 다음 스케일링까지의 유예 시간
    cooldown                = 120

    #Average가 default
    metric_aggregation_type = "Average" #"Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      #metric_interval_upper_bound = 60

      #scaling 개수, 음 or 양
      scaling_adjustment          = 1
    }
  }

  depends_on = [ aws_appautoscaling_target.ecs_app_target ]
}


# scaling out 알람
resource "aws_cloudwatch_metric_alarm" "app_outscaling_metric_alarm" {
  
  alarm_name          = "${local.app_name}-outscaling-metric-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.app_cluster.name}"
    ServiceName = "${aws_ecs_service.app_service.name}"
  }

  #이 알람이 scaling policy을 트리거한다.
  alarm_actions = ["${aws_appautoscaling_policy.ecs_app_scale_out.arn}", 
    var.slack_sns_arn
  ]
}


resource "aws_appautoscaling_policy" "ecs_app_scale_in" {
  
  name               = "${local.web_name}-auto-scaling-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_app_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_app_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_app_target.service_namespace

  #StepScaling
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"

    #cooldown은 스케일링 후 다음 스케일링까지의 유예 시간
    cooldown                = 120

    #Average가 default
    metric_aggregation_type = "Average" #"Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      #metric_interval_upper_bound = 60

      #scaling 개수, 음 or 양
      scaling_adjustment          = -1
    }
  }

  depends_on = [ aws_appautoscaling_target.ecs_app_target ]
}

# scaling in 알람
resource "aws_cloudwatch_metric_alarm" "app_inscaling_metric_alarm" {
  
  count = 0   #지속적인 경고로 일단 제거
  alarm_name          = "${local.app_name}-inscaling-metric-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"  # 임계치보다 낮은 경우 트리거
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "30"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.app_cluster.name}"
    ServiceName = "${aws_ecs_service.app_service.name}"
  }

  #이 알람이 scaling policy을 트리거한다.
  alarm_actions = ["${aws_appautoscaling_policy.ecs_app_scale_in.arn}", 
    var.slack_sns_arn
  ]
}