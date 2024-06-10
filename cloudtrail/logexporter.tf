data "archive_file" "to_s3" {
  type        = "zip"
  source_file = "${path.module}/code/tos3.py"
  output_path = "${path.module}/code/tos3.zip"
}

locals {
   s3_prefix= "cloudtrail2"
}

resource "aws_sns_topic" "to_s3" {
  name = "ldj-cloudtrail-to-s3"
}

resource "aws_lambda_function" "to_s3" {
  function_name = "ldj-cloudtrail-to-s3-lambda"
  filename         = data.archive_file.to_s3.output_path
  handler  = "tos3.lambda_handler"
  runtime  = "python3.8"
  source_code_hash = data.archive_file.to_s3.output_base64sha256
  timeout = 240

  role = aws_iam_role.to_s3.arn

  environment {
    variables = {
      GROUP_NAME = local.cloud_trail_log_group_name
      DESTINATION_BUCKET = var.log_central_bucket_id
      PREFIX = local.s3_prefix
      PERIOD = 1
    }
  }
}


resource "aws_sns_topic_subscription" "slack_subscription" {
  topic_arn = aws_sns_topic.to_s3.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.to_s3.arn
  #lambda_function = aws_lambda_function.slack_notifier.arn
}

resource "aws_lambda_permission" "to_s3" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.to_s3.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.to_s3.arn
}

resource "aws_iam_role" "to_s3" {
  name = "ldj-to-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  
  inline_policy {
    name = "to-s3-policy"
    policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "sns:*",
                "logs:*",
                "cloudwatch:GenerateQuery",
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
    })
  }

}

module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  bus_name = "cloudtrail-log-save-trigger" # "default" bus already support schedule_expression in rules

  attach_lambda_policy = true
  lambda_target_arns   = ["${aws_lambda_function.to_s3.arn}"]

  schedules = {
    lambda-cron = {
      description         = "Trigger for a Lambda"
      schedule_expression = "rate(1 day)"
      timezone            = "Asia/Seoul"
      arn                 = aws_lambda_function.to_s3.arn
      input               = jsonencode({ "job" : "cron-by-rate" })
    }
  }
}