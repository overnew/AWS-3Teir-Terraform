resource "aws_cloudwatch_metric_alarm" "foobar" {
  depends_on = [  ]
  alarm_name                = "ldj-waf-attack-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "BlockedRequests"
  namespace                 = "AWS/WAFV2"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 0
  alarm_description         = "This metric monitors ec2 cpu utilization"

  alarm_actions = [var.slack_alerts]

  dimensions = {
    WebACL = local.web_acl_name
    Region = "${data.aws_region.current.name}"
    Rule = "RateLimit"

  }
  insufficient_data_actions = []
}
