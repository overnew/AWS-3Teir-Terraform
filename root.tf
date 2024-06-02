
terraform  {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

provider "aws" {  #dns log를 위해 생성
  alias  = "us-east-1"
  region = "us-east-1"
}


module "log_central" {
  source = "./logCentral"

  default_tag = {
    project = var.project_name
    owner = var.owner
    part = "log-central"
    env ="test"
  }


  s3_backup_tag = var.s3_backup_tag
}

module "vpc" {
  source = "./vpc"

  project_name = var.project_name
  owner = var.project_name
  part =  "vpc"
  region = var.region
 
  log_central_bucket_arn = module.log_central.log_central_bucket_arn
  log_central_bucket = module.log_central.log_central_bucket
 
  vpc_name = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block
  nat_gw_name = var.nat_gw_name
 
  igw_name = var.igw_name
 
  default_tag = {
    project = var.project_name
    owner = var.owner
    part = "vpc"
    env ="test"
  }

  nat_eip_name = var.nat_eip_name
  public_subnet_data = var.public_subnet_data
  public_subnet_name = var.public_subnet_name
  nfw_subnet_data = var.nfw_subnet_data
  public_rt_name = var.public_rt_name
  private_rt_name = var.private_rt_name

  private_subnet_data = var.private_subnet_data
  private_subnet_name = var.private_subnet_name

  endpoint_sg_id = module.security_groups.endpoint_sg_id
}

module "security_groups" {
  source = "./sg"

  #out put을 통해 vpc_id 사용
  vpc_id = module.vpc.vpc_id

  default_tag = {
    project = var.project_name
    owner = var.owner
    part = "sg"
    env ="test"
  }

  #name의 post fix
  part = "SG"
  vpc_cidr_block = var.vpc_cidr_block

  web_alb_sg_name = var.web_alb_sg_name
  app_alb_sg_name = var.app_alb_sg_name
  web_asg_security_group_name = var.web_asg_security_group_name
  app_asg_security_group_name = var.app_asg_security_group_name
  db_sg_name = var.db_sg_name
}

module "ecs" {
  source = "./ecs"

  default_tag = {
    project = var.project_name
    owner = var.owner
    part = "ecs"
    env ="test"
  }

  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  web_subnet_ids = module.vpc.web_subnet_ids
  app_subnet_ids = module.vpc.app_subnet_ids
  db_subnet_ids = module.vpc.db_subnet_ids
  web_alb_sg_id = module.security_groups.web_alb_sg_id
  app_alb_sg_id = module.security_groups.web_alb_sg_id

  slack_sns_arn = module.alert.slack_sns_arn
}


module "web_service" {
  source = "./3tier"
  count = 0  #3tier변경

  web_asg_security_group_id = module.security_groups.web_asg_security_group_id
  app_asg_security_group_id = module.security_groups.app_asg_security_group_id
  web_alb_sg_id = module.security_groups.web_alb_sg_id
  app_alb_sg_id = module.security_groups.app_alb_sg_id
  db_sg_id = module.security_groups.db_sg_id

  #subnet id 여러개 가져오기
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  web_subnet_ids = module.vpc.web_subnet_ids
  app_subnet_ids = module.vpc.app_subnet_ids
  db_subnet_ids = module.vpc.db_subnet_ids

 web_alb_name = var.web_alb_name
 app_alb_name = var.app_alb_name
 web_asg_name = var.web_asg_name
 app_asg_name = var.app_asg_name
 web_launch_template_name = var.web_launch_template_name
 app_launch_template_name = var.app_launch_template_name

 image_id = var.image_id
 instance_type = var.instance_type
 key_name = var.key_name

 db_name = var.db_name
 instance_type_db = var.instance_type_db

 db_username = var.db_username
 db_password = var.db_password
 db_subnet_group_name = var.db_subnet_group_name

 default_tag = {
    project = var.project_name
    owner = var.owner
    part = "3tier"
    env ="test"
  }

  #vpc endpoint
  region = var.region
  vpc_cidr_block = var.vpc_cidr_block

  secretsmanager_vpc_endpoint_sg_name = var.secretsmanager_vpc_endpoint_sg_name
  secretsmanager_endpoint_name = var.secretsmanager_endpoint_name
}


module "codepipe_web" {
  depends_on = [ module.ecs ]
  source = "./cicd"
  #count = 0  # disable
  
  region = var.region
  project_name = "web-ci-cd"
  user_id = var.user_id

  create_new_repo = true

  source_repository_name = "ldj-web-repo"
  source_repository_branch = "main"

  build_name = "ci-cd-builder"
  deploy_name = "ci-cd-deploy"
 

  deploy_targaet_ecs_cluster_name = module.ecs.web_ecs_cluster_name
  deploy_targaet_ecs_cluster_arn  = module.ecs.web_ecs_cluster_arn
  deploy_targaet_ecs_service_name = module.ecs.web_ecs_service_name
  
  deploy_targaet_lb_arn = module.ecs.lb_arn
  deploy_targaet_lb_lisnter_arn   = module.ecs.lb_lisnter_arn
  deploy_targaet_lb_test_lisnter_arn = module.ecs.lb_test_lisnter_arn
  deploy_targaet_lb_target_group_name = module.ecs.web_lb_target_group_name
  deploy_targaet_lb_test_target_group_name = module.ecs.web_lb_test_target_group_name

  listener_port = 443
  test_listener_port = 8080
}


module "codepipe_app" {
  depends_on = [ module.ecs ]
  source = "./cicd"
  #count = 0  # disable
  
  region = var.region
  project_name = "app-ci-cd"
  user_id = var.user_id

  create_new_repo = true

  source_repository_name = "ldj-app-repo"
  source_repository_branch = "master"

  build_name = "ci-cd-builder"
  deploy_name = "ci-cd-deploy"
 

  deploy_targaet_ecs_cluster_name = module.ecs.app_ecs_cluster_name
  deploy_targaet_ecs_cluster_arn  = module.ecs.app_ecs_cluster_arn
  deploy_targaet_ecs_service_name = module.ecs.app_ecs_service_name
  
  deploy_targaet_lb_arn = module.ecs.lb_arn
  deploy_targaet_lb_lisnter_arn   = module.ecs.lb_lisnter_arn
  deploy_targaet_lb_test_lisnter_arn = module.ecs.lb_test_lisnter_arn
  deploy_targaet_lb_target_group_name = module.ecs.app_lb_target_group_name
  deploy_targaet_lb_test_target_group_name = module.ecs.app_lb_test_target_group_name

  listener_port = 443
  test_listener_port = 8080
}

#alb와 도메인 연결
module "route53" {
  source = "./domain"

  depends_on = [ module.ecs ]  #domain은 alb생성 후에

  alb_dns_name = module.ecs.alb_dns_name
  alb_zone_id = module.ecs.alb_zone_id
  
}


##WAF
module "waf" {
  source = "./waf"

  target_alb_arn = module.ecs.lb_arn

  default_tag = {
    project = var.project_name
    owner = var.owner
    part = "waf"
    env ="test"
  }

  s3_backup_tag = var.s3_backup_tag
}


# CloudTrail
module "cloudtrail" {
  source = "./cloudtrail"

  default_tag = {
    project = var.project_name
    owner = var.owner
    part = "cloudtrail"
    env ="test"
  }
  default_region = var.region
  service_table_name = "user_table"

  log_central_bucket_arn = module.log_central.log_central_bucket_arn
  log_central_bucket_id = module.log_central.log_central_bucket_id
}

module "config" {
  source = "./config"

  default_tag = {
    project = var.project_name
    owner = var.owner
    part = "config"
    env ="test"
  }

  log_central_bucket = module.log_central.log_central_bucket

}

module "alert" {
  source = "./alert"
}

module "backup" {
  source = "./backup"

  s3_backup_tag = var.s3_backup_tag
}

#DNS log 
# 타리전 사용을 위해 root에 선언
resource "aws_route53_query_log" "milipresso_log" {
  depends_on = [module.route53 ,aws_cloudwatch_log_resource_policy.route53-query-logging-policy]

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.aws_route53_milipresso.arn
  zone_id                  = module.route53.zone_id
  #data.aws_route53_zone.milipresso_zone.zone_id
}

resource "aws_cloudwatch_log_group" "aws_route53_milipresso" {
  provider = aws.us-east-1
  
  name              = "/aws/route53/milipresso.shop"  # "${data.aws_route53_zone.milipresso_zone.name}"
  retention_in_days = 30

  
  tags = {
    owner = "ldj"
    ExportToS3= "true"
  }
}

# Example CloudWatch log resource policy to allow Route53 to write logs
# to any log group under /aws/route53/*

data "aws_iam_policy_document" "route53-query-logging-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {
  provider = aws.us-east-1
  
  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}