data "aws_acm_certificate" "mili_acm" {
  domain = "*.milipresso.shop"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}