output "vpc_id" {
  value = aws_vpc.vpc_name.id
}

output "public_subnet_ids" {
  value = values(aws_subnet.public_subnets)[*].id
}

output "private_subnet_ids" {
  value = values(aws_subnet.private_subnets)[*].id
}

output "web_subnet_ids" {
  value = [aws_subnet.private_subnets["web_sub_1a"].id,
    aws_subnet.private_subnets["web_sub_2c"].id]
}

output "app_subnet_ids" {
  value = [aws_subnet.private_subnets["app_sub_1a"].id,
    aws_subnet.private_subnets["app_sub_2c"].id]
}

output "endpoint_subnet_ids" {
  value = [aws_subnet.private_subnets["endpoint_sub_1a"].id,
    aws_subnet.private_subnets["endpoint_sub_2c"].id]
}