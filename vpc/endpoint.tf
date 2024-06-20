
locals {
  s3_gateway_name = "s3-gw"
  dynamodb_gateway_name = "dynamodb-gw"
  #secret_manager_endpoint_name = "secret-manager-endpoint"

  endpoint_subnet_ids = [aws_subnet.private_subnets["endpoint_sub_1a"].id,
  aws_subnet.private_subnets["endpoint_sub_2c"].id]
  endpoint_postfix_name = "vpc-endpoint"
}

#Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc_name.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private_rt_a.id, aws_route_table.private_rt_c.id, 
      aws_route_table.private_rt_default_a.id, aws_route_table.private_rt_default_c.id]

  tags = merge(
    {
      Name = local.s3_gateway_name
    },
    var.default_tag
  )  
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.vpc_name.id
  service_name = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private_rt_a.id, aws_route_table.private_rt_c.id, 
     aws_route_table.private_rt_default_a.id, aws_route_table.private_rt_default_c.id]

  tags = merge(
    {
      Name = local.dynamodb_gateway_name
    },
    var.default_tag
  )  
}


#Interface endpoints
#AZ마다의 이중화


module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = aws_vpc.vpc_name.id
  security_group_ids = [var.endpoint_sg_id]

  endpoints = {
    
    secretsmanager = {
      service    = "secretsmanager"
      private_dns_enabled = true
      auto_accept = true
      subnet_ids = local.endpoint_subnet_ids
      tags       = { Name = "secretsmanager-${local.endpoint_postfix_name}" }
    },
    ecrdkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      auto_accept = true
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "ecr.dkr-${local.endpoint_postfix_name}" }
    },
    ecrapi = {
      service             = "ecr.api"
      private_dns_enabled = true
      auto_accept = true
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "ecr.api-${local.endpoint_postfix_name}" }
    },
    monitoring = {
      service             = "monitoring"
      private_dns_enabled = true
      auto_accept = true
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "monitoring-${local.endpoint_postfix_name}" }
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      auto_accept = true
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "logs-${local.endpoint_postfix_name}" }
    },
    /*amp = {
      service             = "aps"
      private_dns_enabled = true
      auto_accept = true
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "amp-${local.endpoint_postfix_name}" }
    },*/
    amp-workspace = {
      service             = "aps-workspaces"
      private_dns_enabled = true
      auto_accept = true
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "amp-workspace-${local.endpoint_postfix_name}" }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      auto_accept = true
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "ssm-${local.endpoint_postfix_name}" }
    }
  }

  tags = var.default_tag
}

