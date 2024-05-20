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