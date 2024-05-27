resource "aws_route53_record" "alias_route53_record" {
  zone_id = data.aws_route53_zone.milipresso_zone.zone_id
  name    = "www.${data.aws_route53_zone.milipresso_zone.name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "milipresso_zone" {
  name = "milipresso.shop."
  private_zone = false
}