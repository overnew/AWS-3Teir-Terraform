

## Secrets Manager Endpoint
# Security Group of VPC Endpoint (Secrets Manager)
resource "aws_security_group" "secretsmanager_vpc_endpoint_sg" {
  name = var.secretsmanager_vpc_endpoint_sg_name
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
      Name = var.secretsmanager_vpc_endpoint_sg_name
    },
    var.default_tag
  )  
}

# Secrets Manager VPC Endpoint
resource "aws_vpc_endpoint" "secretsmanager_endpoint" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.secretsmanager_vpc_endpoint_sg.id
  ]

  private_dns_enabled = true
  auto_accept = true

  tags = merge(
    {
      Name = var.secretsmanager_endpoint_name
    },
    var.default_tag
  )  
}

#서브넷 마다 하나씩 필요
resource "aws_vpc_endpoint_subnet_association" "secretsmanager_endpoint" {
  #count           = length(var.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager_endpoint.id
  subnet_id       = var.public_subnet_ids[0]
}

resource "aws_vpc_endpoint_subnet_association" "secretsmanager_endpoint2" {
  #count           = length(var.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager_endpoint.id
  subnet_id       = var.public_subnet_ids[1]
}

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