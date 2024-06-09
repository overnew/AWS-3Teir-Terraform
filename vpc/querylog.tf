resource "aws_route53_resolver_query_log_config" "vpc_query_log" {
  name            = "service-querylog"
  destination_arn = var.log_central_bucket_arn

  tags =  var.default_tag
}

resource "aws_route53_resolver_query_log_config_association" "query_log_ass" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.vpc_query_log.id
  resource_id                  = aws_vpc.vpc_name.id
}

