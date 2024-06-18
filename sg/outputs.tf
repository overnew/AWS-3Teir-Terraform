output "web_security_group_id" {
  value = aws_security_group.web_security_group.id
}

output "app_security_group_id" {
  value = aws_security_group.app_security_group.id
}

output "web_alb_sg_id" {
  value = aws_security_group.web_alb_sg.id
}

output "endpoint_sg_id"{
  value = aws_security_group.vpc_endpoint_sg.id
}