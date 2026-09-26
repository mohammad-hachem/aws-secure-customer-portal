data "aws_route53_zone" "securanova" {
  name         = "securanova.net."
  private_zone = false
}

resource "aws_acm_certificate" "portal" {
  domain_name = "securanova.net"

  subject_alternative_names = [
    "*.securanova.net"
  ]

  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "securanova.net"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

locals {
  acm_validation = one([
    for dvo in aws_acm_certificate.portal.domain_validation_options : dvo
    if dvo.domain_name == "securanova.net"
  ])
}

resource "aws_route53_record" "acm_validation" {
  zone_id = data.aws_route53_zone.securanova.zone_id

  name = local.acm_validation.resource_record_name
  type = local.acm_validation.resource_record_type
  ttl  = 300

  records = [
    local.acm_validation.resource_record_value
  ]
}

resource "aws_route53_record" "portal" {
  zone_id = data.aws_route53_zone.securanova.zone_id
  name    = "portal.securanova.net"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portal.domain_name
    zone_id                = aws_cloudfront_distribution.portal.hosted_zone_id
    evaluate_target_health = false
  }
}
