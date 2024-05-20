locals {
  deploy_name = "${var.project_name}-${var.deploy_name}"
}

resource "aws_codedeploy_app" "main" {
  compute_platform = "ECS"
  name             = local.deploy_name

  
  tags = local.default_tag
}

resource "aws_codedeploy_deployment_group" "main" {
  deployment_group_name  = local.deploy_name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  app_name               = aws_codedeploy_app.main.name
  service_role_arn       = aws_iam_role.cd_service_role.arn
  
  auto_rollback_configuration {
    enabled = true
    events  = [
      "DEPLOYMENT_FAILURE"
    ]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = data.aws_ecs_cluster.main.cluster_name
    service_name = data.aws_ecs_service.main.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [
          data.aws_lb_listener.main.arn
        ]
      }
      test_traffic_route {
        listener_arns = [
          data.aws_lb_listener.test.arn
        ]
      }
      target_group {
        name = data.aws_lb_target_group.blue.name
      }
      target_group {
        name = data.aws_lb_target_group.green.name
      }
    }
  }
  
  tags = local.default_tag
}



#대상을 설정
data "aws_ecs_cluster" "main" {
  cluster_name = var.deploy_targaet_ecs_cluster_name
}

data "aws_ecs_service" "main" {
  depends_on = [ data.aws_ecs_cluster.main ]
  cluster_arn = var.deploy_targaet_ecs_cluster_arn
  service_name = var.deploy_targaet_ecs_service_name
}

data "aws_lb_listener" "main" {
  load_balancer_arn = var.deploy_targaet_lb_arn
  port = var.listener_port
}

data "aws_lb_listener" "test" {
  load_balancer_arn = var.deploy_targaet_lb_arn
  port = var.test_listener_port
}

data "aws_lb_target_group" "blue" {
  tags = {
    Name = var.deploy_targaet_lb_target_group_name
  }
}

data "aws_lb_target_group" "green" {
  tags = {
    Name = var.deploy_targaet_lb_test_target_group_name
  }
}

resource aws_iam_role cd_service_role {
  name               = "${local.deploy_name}-role"
  assume_role_policy = data.aws_iam_policy_document.cd_assume_role_policy.json

  tags = local.default_tag
}

resource aws_iam_role_policy_attachment cd_service_role_policy {
  role       = aws_iam_role.cd_service_role.id
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

data aws_iam_policy_document cd_assume_role_policy {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}