#https://yogae.tistory.com/29
# 특정 IP의 과도한 요청 차단
resource "aws_wafv2_web_acl" "my_web_acl" {
  name  = "my-web-acl"
  scope = "REGIONAL"  #or CLOUDFRONT 

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimit"
    priority = 1

    action {
      block {}
    }

    statement {

      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 500
        scope_down_statement {
          not_statement {
            statement {  #특정 ip는 허용
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.white_list_ip_list.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "my-web-acl"
    sampled_requests_enabled   = false
  }
}

#정책
resource "aws_wafv2_ip_set" "white_list_ip_list" {
  name               = "test-name"
  description        = "white ip set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["127.0.0.1/32"] # 조건에서 제외시킬 ip 추가
}

#ALB와 연결
resource "aws_wafv2_web_acl_association" "web_acl_association_my_lb" {
  resource_arn = var.target_alb_arn
  web_acl_arn  = aws_wafv2_web_acl.my_web_acl.arn
}


#log Setting
