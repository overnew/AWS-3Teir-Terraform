
locals {
  s3_gateway_name = "s3-gw"
  dynamodb_gateway_name = "dynamodb-gw"
  #secret_manager_endpoint_name = "secret-manager-endpoint"

  endpoint_subnet_ids = [aws_subnet.private_subnets["db_sub_1a"].id,
  aws_subnet.private_subnets["db_sub_2c"].id]
  endpoint_postfix_name = "vpc-endpoint"
}

#Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc_name.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private_rt_a.id, aws_route_table.private_rt_c.id, aws_route_table.private_rt_default.id]

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
  route_table_ids = [aws_route_table.private_rt_a.id, aws_route_table.private_rt_c.id, aws_route_table.private_rt_default.id]

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
    /*
    s3 = {
      # interface endpoint
      service             = "s3"
      private_dns_enabled = true
      tags                = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      # gateway endpoint
      service         = "dynamodb"
      route_table_ids = ["rt-12322456", "rt-43433343", "rt-11223344"]
      tags            = { Name = "dynamodb-vpc-endpoint" }
    },*/
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
      #security_group_ids  = ["sg-987654321"]
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "ecr.dkr-${local.endpoint_postfix_name}" }
    },
    ecrapi = {
      service             = "ecr.api"
      private_dns_enabled = true
      auto_accept = true
      #security_group_ids  = ["sg-987654321"]
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "ecr.api-${local.endpoint_postfix_name}" }
    },
    monitoring = {
      service             = "monitoring"
      private_dns_enabled = true
      auto_accept = true
      #security_group_ids  = ["sg-987654321"]
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "monitoring-${local.endpoint_postfix_name}" }
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      auto_accept = true
      #security_group_ids  = ["sg-987654321"]
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "logs-${local.endpoint_postfix_name}" }
    },
    amp = {
      service             = "aps"
      private_dns_enabled = true
      auto_accept = true
      #security_group_ids  = ["sg-987654321"]
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "amp-${local.endpoint_postfix_name}" }
    },
    amp-workspace = {
      service             = "aps-workspaces"
      private_dns_enabled = true
      auto_accept = true
      #security_group_ids  = ["sg-987654321"]
      subnet_ids          = local.endpoint_subnet_ids
      tags = { Name = "amp-workspace-${local.endpoint_postfix_name}" }
    }
  }

  tags = var.default_tag
}



/*
## Secrets Manager Endpoint
resource "aws_vpc_endpoint" "secretsmanager_endpoint" {
  vpc_id = aws_vpc.vpc_name.id
  service_name = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.endpoint_sg_id
  ]

  private_dns_enabled = true
  auto_accept = true

  tags = merge(
    {
      Name = local.secret_manager_endpoint_name
    },
    var.default_tag
  )  
}

#AZ 마다 하나씩 배치하여 가용성 높임
resource "aws_vpc_endpoint_subnet_association" "secretsmanager_endpoint" {
  #count           = length(var.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager_endpoint.id
  subnet_id       = aws_subnet.private_subnets["db_sub_1a"].id
}

resource "aws_vpc_endpoint_subnet_association" "secretsmanager_endpoint2" {
  #count           = length(var.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager_endpoint.id
  subnet_id       = aws_subnet.private_subnets["db_sub_2c"].id
}
*/

/*
resource "aws_vpc_endpoint_subnet_association" "secretsmanager_endpoint" {
  #count           = length(var.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager_endpoint.id
  subnet_id       = var.app_subnet_ids[0]
}

resource "aws_vpc_endpoint_subnet_association" "secretsmanager_endpoint2" {
  #count           = length(var.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager_endpoint.id
  subnet_id       = var.app_subnet_ids[1]
}
*/

/*
# Interface Type Endpoint 

# endpoint 용의 SG
# Security Group of VPC Endpoint (API Gateway )
resource "aws_security_group" "apigateway_vpc_endpoint_sg" {
  name = var.apigateway_vpc_endpoint_sg_name
  vpc_id = var.vpc_id

  #https 트래픽만 받음
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"

    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Internal outbound any traffic"
  }

  tags = merge(
    {
      Name = var.apigateway_vpc_endpoint_sg_name
    },
    var.default_tag
  )  
}

## API Gateway Endpoint
resource "aws_vpc_endpoint" "apigateway_endpoint" {
  vpc_id = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.apigateway_vpc_endpoint_sg.id
  ]

  private_dns_enabled = true
  auto_accept         = true

  tags = merge(
    {
      Name = var.apigateway_endpoint_name
    },
    var.default_tag
  )  
}

#Provides a resource to create an association between a VPC endpoint and a subnet.
resource "aws_vpc_endpoint_subnet_association" "apigateway_endpoint" {
  #count           = length(var.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.apigateway_endpoint.id
  subnet_id       = var.app_subnet_ids
  #element(aws_subnet.private.*.id, count.index)
}
*/