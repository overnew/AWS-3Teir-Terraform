#us-east-1 리전의 경우
/*
resource "aws_route53_query_log" "milipresso_log" {
  depends_on = [aws_cloudwatch_log_resource_policy.route53-query-logging-policy]

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.aws_route53_milipresso.arn
  zone_id                  = data.aws_route53_zone.milipresso_zone.zone_id
}

resource "aws_cloudwatch_log_group" "aws_route53_milipresso" {
  #provider = aws.us-east-1
  
  name              = "/aws/route53/milipresso.shop"  # "${data.aws_route53_zone.milipresso_zone.name}"
  retention_in_days = 30

  
  tags = {
    owner = "ldj"
    ExportToS3= "true"
  }
}

# Example CloudWatch log resource policy to allow Route53 to write logs
# to any log group under /aws/route53/*

data "aws_iam_policy_document" "route53-query-logging-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {
  #provider = aws.us-east-1
  
  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}
*/