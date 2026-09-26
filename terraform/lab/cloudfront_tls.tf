resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name       = "portal.securanova.net"
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  cloudfront_acm_validation = one(
    aws_acm_certificate.cloudfront.domain_validation_options
  )
}

resource "aws_route53_record" "cloudfront_acm_validation" {
  zone_id = data.aws_route53_zone.securanova.zone_id

  name = local.cloudfront_acm_validation.resource_record_name
  type = local.cloudfront_acm_validation.resource_record_type
  ttl  = 300

  records = [
    local.cloudfront_acm_validation.resource_record_value
  ]
}

resource "aws_route53_record" "origin" {
  zone_id = data.aws_route53_zone.securanova.zone_id
  name    = "origin.securanova.net"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.app.dns_name}"
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = false
  }
}
