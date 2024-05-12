#cluster

locals {
  cluster_name = "web-serivce-ecs"
  web_server_name = "web-server"
}

#cluster
resource "aws_ecs_cluster" "web_service" {
  name = local.cluster_name

  #setting {   # 컨테이너 지표 감시 가능
  #  name  = "containerInsights"
  #  value = "enabled"
  #}

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

  tags = merge(
    {
      Name = format("%s-%s",local.web_server_name ,"task") 
    },
    var.default_tag
  )
}

resource "aws_ecs_service" "web_server" {
  name            = local.web_server_name
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
  
  network_configuration {
    subnets           = [var.web_subnet_ids[0],var.web_subnet_ids[1]]
    assign_public_ip  = false
    security_groups   = [var.web_alb_sg_id]
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "first"
    container_port   = 80
  }
  depends_on  = [aws_lb_listener.listener]

  #placement_constraints {
  #  type       = "memberOf"
  #  expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #}
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
                "logs:CreateLogStream",
                "logs:PutLogEvents"
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