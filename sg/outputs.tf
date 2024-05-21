output "web_asg_security_group_id" {
  value = aws_security_group.web_asg_security_group.id
}

output "app_asg_security_group_id" {
  value = aws_security_group.app_asg_security_group.id
}

output "web_alb_sg_id" {
  value = aws_security_group.web_alb_sg.id
}

output "app_alb_sg_id" {
  value = aws_security_group.app_alb_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "endpoint_sg_id"{
  value = aws_security_group.vpc_endpoint_sg.id
}