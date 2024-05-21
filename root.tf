
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

module "vpc" {
  source = "./vpc"

 project_name = var.project_name
 owner = var.project_name
 part =  "vpc"
 region = var.region

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

  listener_port = 80
  test_listener_port = 8080
}


module "codepipe_app" {
  depends_on = [ module.ecs ]
  source = "./cicd"
  
  region = var.region
  project_name = "app-ci-cd"
  user_id = var.user_id

  create_new_repo = true

  source_repository_name = "ldj-app-repo"
  source_repository_branch = "main"

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

  listener_port = 80
  test_listener_port = 8080
}

/*

#web security group#

resource "aws_security_group" "alb-web-sg" {
  name        = var.alb-sg-web-name
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb-sg-web-name
  }
}

#app security group#

resource "aws_security_group" "alb-app-sg" {
  name        = var.alb-sg-app-name
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web-asg-security-group.id]
    
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb-sg-app-name
  }
}

#database security group#

resource "aws_security_group" "db-sg" {
  name        = var.db-sg-name
  description = "DataBase Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {

    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app-asg-security-group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.db-sg-name
  }
}

#web load balancer#

resource "aws_lb" "web-alb" {
  name               = var.alb-web-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-web-sg.id]
  subnets            = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]
}

#app load balancer#

resource "aws_lb" "app-alb" {
  name               = var.alb-app-name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-app-sg.id]
  subnets            = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]

}



#web auto scaling group#

resource "aws_autoscaling_group" "web-asg" {
  name =   var.asg-web-name
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  target_group_arns   = [aws_lb_target_group.web-target-group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]

  launch_template {
    id      = aws_launch_template.web-launch-template.id
    version = aws_launch_template.web-launch-template.latest_version
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

#web auto scaling security group#

resource "aws_security_group" "web-asg-security-group" {
  name        = var.asg-sg-web-name
  description = "ASG Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description = "HTTP from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb-web-sg.id]
  }


    ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg-sg-web-name
  }
}

#app auto scaling group#

resource "aws_autoscaling_group" "app-asg" {
  name =   var.asg-app-name
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  target_group_arns   = [aws_lb_target_group.app-target-group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]

  launch_template {
    id      = aws_launch_template.app-launch-template.id
    version = aws_launch_template.app-launch-template.latest_version
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


#app auto scaling security group#

resource "aws_security_group" "app-asg-security-group" {
  name        = var.asg-sg-app-name
  description = "ASG Security Group"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description = "HTTP from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb-app-sg.id]
  }

    ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.web-asg-security-group.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg-sg-app-name
  }
}


#web launch template#

resource "aws_launch_template" "web-launch-template" {
  name          = var.launch-template-web-name
  image_id      = var.image-id
  instance_type = var.instance-type
  key_name      = var.key-name
  user_data     = filebase64("${path.module}/web_userdata.sh")

network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.web-asg-security-group.id]
  }

tag_specifications {

    resource_type = "instance"
    tags = {
      Name = var.launch-template-web-name
    }
  }
}

#app launch template#
# 여기서 WAS 동작용 코드를를 넣어줘야 한다.
resource "aws_launch_template" "app-launch-template" {
  name          = var.launch-template-app-name
  image_id      = var.image-id
  instance_type = var.instance-type
  key_name      = var.key-name
  user_data     = filebase64("${path.module}/app_userdata.sh")

  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.app-asg-security-group.id]
  }

  tag_specifications {

    resource_type = "instance"
    tags = {
      Name = var.launch-template-app-name
    }
  }
  
} 

#web target group#

resource "aws_lb_target_group" "web-target-group" {
  name     = "tg-web-name"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_name.id
  health_check {
    path = "/"
    matcher = 200
  }

}

resource "aws_lb_listener" "my_web_alb_listener" {
 load_balancer_arn = aws_lb.web-alb.arn 
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.web-target-group.arn
 }
}

#app target group#

resource "aws_lb_target_group" "app-target-group" {
  name     = "tg-app-name"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_name.id
  health_check {
    path = "/"
    matcher = 200
  }
}

resource "aws_lb_listener" "my_app_alb_listener" {
 load_balancer_arn = aws_lb.app-alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.app-target-group.arn
 }
}

#database instance#

resource "aws_db_instance" "database" {
  allocated_storage    = 10
  db_name              = var.db-name
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.instance-type-db
  username             = var.db-username
  password             = var.db-password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi_az = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.database-subnet-group.name
}


*/