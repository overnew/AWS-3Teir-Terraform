data "archive_file" "slack_noti" {
  type        = "zip"
  source_file = "${path.module}/code/slack_notifier.py"
  output_path = "${path.module}/code/slack_notifier.zip"
}

resource "aws_sns_topic" "slack_alerts" {
  name = "ldj-slack-alerts"
}

resource "aws_lambda_function" "slack_notifier" {
  function_name = "ldj-skack-lambda"
  filename         = data.archive_file.slack_noti.output_path
  handler  = "slack_notifier.lambda_handler"
  runtime  = "python3.8"
  source_code_hash = data.archive_file.slack_noti.output_base64sha256
  

  role = aws_iam_role.slack_notifier.arn

  environment {
    variables = {
      SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
      #var.slack_webhook_url
    }
  }
}



resource "aws_sns_topic_subscription" "slack_subscription" {
  topic_arn = aws_sns_topic.slack_alerts.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.slack_notifier.arn
  #lambda_function = aws_lambda_function.slack_notifier.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.slack_alerts.arn
}

resource "aws_iam_role" "slack_notifier" {
  name = "slack-notifier-role"

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
    name = "slack_notifier_policy"
    policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "sns:*" #Publish
            ],
            "Resource": "*"
        }
    ]
    })
  }

}
