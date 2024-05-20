variable "project_name" {}

variable "region" {}
variable "user_id" {}

variable "create_new_repo" {}

variable "source_repository_name" {}

variable "source_repository_branch" {}

variable "build_name" {}

variable "deploy_name" {}

variable "deploy_targaet_ecs_cluster_name" {}
variable "deploy_targaet_ecs_cluster_arn" {}
variable "deploy_targaet_ecs_service_name" {}

variable "deploy_targaet_lb_arn" {}
variable "deploy_targaet_lb_lisnter_arn" {}
variable "deploy_targaet_lb_test_lisnter_arn" {}
variable "deploy_targaet_lb_target_group_name" {}
variable "deploy_targaet_lb_test_target_group_name" {}

variable "listener_port" {}
variable "test_listener_port" {}