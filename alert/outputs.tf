output "slack_sns_arn" {
  value = aws_sns_topic.slack_alerts.arn
}
