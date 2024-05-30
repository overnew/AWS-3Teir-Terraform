

resource "aws_cloudtrail" "mytrail" {
  #depends_on = [aws_s3_bucket_policy.mytrail]

  name                          = "mytrail"
  enable_logging = true     #로깅 활성화

  # 현재 리전으로만 설정
  is_multi_region_trail = false

  s3_bucket_name                = var.log_central_bucket_id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = false


  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" 
  cloud_watch_logs_role_arn = aws_iam_role.cloudwatch_for_cloudtrail.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::DynamoDB::Table"
      #해당 리전을 대상으로 모든 테이블의 감시, 특정 테이블도 선택가능.
      values = ["arn:aws:dynamodb:${var.default_region}:${data.aws_caller_identity.current.account_id}:table/${var.service_table_name}"]
    }
  }  
  insight_selector {
    insight_type = "ApiCallRateInsight" # and ApiErrorRateInsight
  }

  #더 섬세한 로그 전달 세팅이 필요한 경우 
  #advanced_event_selector

  tags = var.default_tag
}

#resource "aws_s3_bucket" "mytrail" {
#  bucket        = "ldj-all-log-${random_string.bucket_random_id.id}" 
#  force_destroy = true
#}
/*
data "aws_iam_policy_document" "mytrail_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [var.log_central_bucket_arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/mytrail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${var.log_central_bucket_arn}/cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/mytrail"]
    }
  }
}

resource "aws_s3_bucket_policy" "mytrail" {
  bucket = aws_s3_bucket.mytrail.id
  policy = data.aws_iam_policy_document.mytrail_policy.json
  
}*/

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# 랜덤 수 생성기
resource "random_string" "bucket_random_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric  = true
  special = false
}