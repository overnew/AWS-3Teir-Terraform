resource "aws_flow_log" "main_vpc_flow" {
  log_destination      = var.log_central_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc_name.id
  
  # format도 설정가능
  log_format = "$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"

  #전송 시간으 60초 또는 600초(default)
  max_aggregation_interval = 60
  #destination_options {
  #  file_format        = "parquet" #plain-text가 기본
  #  per_hour_partition = true   #비용 절감을 위해서 시간단위로도 전송 가능
  #}

  tags = var.default_tag
}