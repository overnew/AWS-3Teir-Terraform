#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration
resource "aws_cloudwatch_log_group" "example" {
  name = "aws-waf-logs-some-uniq-suffix"

  tags = merge(
    {
      "${var.s3_backup_tag}" = "true"
    },
    var.default_tag
  )
}

resource "aws_wafv2_web_acl_logging_configuration" "to_cloudwatch" {
  log_destination_configs = [aws_cloudwatch_log_group.example.arn]
  resource_arn            = aws_wafv2_web_acl.my_web_acl.arn

    logging_filter {
    default_behavior = "KEEP"
/*
    filter {
      behavior = "DROP"

      condition {
        action_condition {
          action = "COUNT"
        }
      }

      condition {
        label_name_condition {
          label_name = "awswaf:111122223333:rulegroup:testRules:LabelNameZ"
        }
      }

      requirement = "MEETS_ALL"
    }*/

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "BLOCK" #or ALLOW, BLOCK, COUNT
        }
      }

      requirement = "MEETS_ALL"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "example" {
  policy_document = data.aws_iam_policy_document.example.json
  policy_name     = "webacl-policy-uniq-name"
}

data "aws_iam_policy_document" "example" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.example.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


#to S3
resource "aws_wafv2_web_acl_logging_configuration" "to_s3" {
  log_destination_configs = [aws_s3_bucket.waf_flow_bucket.arn]
  resource_arn            = aws_wafv2_web_acl.my_web_acl.arn

    logging_filter {
    default_behavior = "KEEP"
/*
    filter {
      behavior = "DROP"

      condition {
        action_condition {
          action = "COUNT"
        }
      }

      condition {
        label_name_condition {
          label_name = "awswaf:111122223333:rulegroup:testRules:LabelNameZ"
        }
      }

      requirement = "MEETS_ALL"
    }*/

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "BLOCK" #or ALLOW, BLOCK, COUNT
        }
      }

      requirement = "MEETS_ALL"
    }
  }
}

#s3 선언
resource "aws_s3_bucket" "waf_flow_bucket" {
  bucket        = "aws-waf-logs-ldj-bucket--${random_string.bucket_random_id.id}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "waf_flow_bucket_ownership_control" {
  bucket = aws_s3_bucket.waf_flow_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "waf_flow_bucket_public_access_block" {
  bucket = aws_s3_bucket.waf_flow_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_string" "bucket_random_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric  = true
  special = false
}