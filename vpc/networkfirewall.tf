resource "aws_networkfirewall_firewall" "inspection_vpc_anfw" {
  name                = "NetworkFirewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.anfw_policy.arn
  vpc_id              = aws_vpc.vpc_name.id

  dynamic "subnet_mapping" {
    for_each = [aws_subnet.nfw_subnets["nfw_sub_1a"].id, aws_subnet.nfw_subnets["nfw_sub_2c"].id] #aws_subnet.nfw_subnets[*].id

    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = var.default_tag
}

resource "aws_networkfirewall_firewall_policy" "anfw_policy" {
  name = "firewall-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:pass"]#aws:forward_to_sfe
    stateless_fragment_default_actions = ["aws:pass"]
  }
  
  tags = var.default_tag
}


# log 세팅
resource "aws_cloudwatch_log_group" "anfw_alert_log_group" {
  name = "/aws/network-firewall/alert"
}

resource "aws_networkfirewall_logging_configuration" "anfw_alert_logging_configuration" {
  firewall_arn = aws_networkfirewall_firewall.inspection_vpc_anfw.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.anfw_alert_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    #log_destination_config {
    #  log_destination = {
    #    bucketName = aws_s3_bucket.anfw_flow_bucket.bucket
    #  }
    #  log_destination_type = "S3"
    #  log_type             = "FLOW"
    #}
  }
}

/* #모듈로 진행시
module "network_firewall" {
  source = "terraform-aws-modules/network-firewall/aws"

  # Firewall
  name        = "testNFW"
  description = "Example network firewall"

  vpc_id = aws_vpc.vpc_name.id
  subnet_mapping = {
    subnet1 = {
      subnet_id       = aws_subnet.nfw_subnets["nfw_sub_1a"].id
      ip_address_type = "IPV4"
    }
    subnet2 = {
      subnet_id       = aws_subnet.nfw_subnets["nfw_sub_2c"].id
      ip_address_type = "IPV4"
    }
  }

  # Logging configuration
  create_logging_configuration = true
  logging_configuration_destination_config = [
    {
      log_destination = {
        logGroup = "/aws/network-firewall/example"
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    },
    {
      log_destination = {
        bucketName = "s3-example-bucket-firewall-flow-logs"
        prefix     = "example"
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  ]

  # Policy
  policy_name        = "example"
  policy_description = "Example network firewall policy"

  policy_stateful_rule_group_reference = {
    one = {
      priority     = 0
      resource_arn = "arn:aws:network-firewall:us-east-1:1234567890:stateful-rulegroup/example"
    }
  }

  policy_stateless_default_actions          = ["aws:pass"]
  policy_stateless_fragment_default_actions = ["aws:drop"]
  policy_stateless_rule_group_reference = {
    one = {
      priority     = 0
      resource_arn = "arn:aws:network-firewall:us-east-1:1234567890:stateless-rulegroup/example"
    }
  }

  tags = var.default_tag
}
*/