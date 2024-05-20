#ecs
output "web_ecs_cluster_name" {
  value = aws_ecs_cluster.web_cluster.name
}

output "web_ecs_cluster_arn" {
  value = aws_ecs_cluster.web_cluster.arn
}

output "web_ecs_service_name" {
  value = aws_ecs_service.web_service.name
}

output "app_ecs_cluster_name" {
  value = aws_ecs_cluster.app_cluster.name
}

output "app_ecs_cluster_arn" {
  value = aws_ecs_cluster.app_cluster.arn
}

output "app_ecs_service_name" {
  value = aws_ecs_service.app_service.name
}

#alb
output "lb_arn" {
  value = aws_alb.web_alb.arn
}

output "lb_lisnter_arn" {
  value = aws_lb_listener.service_listener.arn
}

output "lb_test_lisnter_arn" {
  value = aws_lb_listener.test_listener.arn
}

output "web_lb_target_group_name" {
  value = aws_lb_target_group.web_target_group.name
}

output "web_lb_test_target_group_name" {
  value = aws_lb_target_group.web_test_target_group.name
}

output "app_lb_target_group_name" {
  value = aws_lb_target_group.app_target_group.name
}

output "app_lb_test_target_group_name" {
  value = aws_lb_target_group.app_test_target_group.name
}