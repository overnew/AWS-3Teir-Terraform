locals {
  cloud_trail_log_group_name = "cloud-trail-log"
}

# cloud watch log
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = local.cloud_trail_log_group_name

  tags = var.default_tag
}

/*
data "aws_iam_policy_document" "cloudtrail_to_cloudwatch" {
  statement {
    sid    = "CreateLogGroupByCloudTrail"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com"]
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.cloudtrail.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.cloudtrail.name}:${data.aws_caller_identity.cloudtrail.account_id}:*"]
      variable = "aws:SourceArn"
    }
    #["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloud_trail_log_group_name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${data.aws_region.current.name}*"]#aws_s3_bucket.mytrail.arn]
    #        "arn:aws:logs:ap-northeast-1:851725230407:log-group:aws-cloudtrail-logs-851725230407-586af5d9:log-stream:851725230407_CloudTrail_ap-northeast-1*"
  }
}
*/

resource "aws_iam_role" "cloudwatch_for_cloudtrail" {
  name = "ldj-cloudwatch-for-cloudtrail-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com"]
        }
      },
    ]
  })
  

  inline_policy {
    name = "cloudwatch-for-cloudtrail-role"
    
    policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "logs:CreateLogStream", "logs:PutLogEvents"
            ],
            Resource: "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
        }
    ]
    })
  }

  tags = var.default_tag
}


/*
data "aws_iam_policy_document" "cloudtrail_to_cloudwatch" {
  statement {
    sid    = "CreateLogGroupByCloudTrail"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
    #["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloud_trail_log_group_name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${data.aws_region.current.name}*"]#aws_s3_bucket.mytrail.arn]
    #        "arn:aws:logs:ap-northeast-1:851725230407:log-group:aws-cloudtrail-logs-851725230407-586af5d9:log-stream:851725230407_CloudTrail_ap-northeast-1*"
  }
}*/

/*
resource "aws_iam_role" "cloudwatch_for_cloudtrail" {
  name               = "ldj-cloudwatch-for-cloudtrail-role"
  #path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_to_cloudwatch.json

  tags = var.default_tag
}
*/

