data "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.us_east_1

  name  = "CreatedByCloudFront-dce6a1b5"
  scope = "CLOUDFRONT"
}

resource "aws_cloudfront_distribution" "portal" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Single website configuration"

  aliases = [
    "portal.securanova.net"
  ]

  price_class  = "PriceClass_All"
  http_version = "http2"

  web_acl_id = data.aws_wafv2_web_acl.cloudfront.arn

  origin {
    domain_name = "origin.securanova.net"
    origin_id   = "origin.securanova.net-mu3vopkk883"

    connection_attempts = 3
    connection_timeout  = 10

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
      ip_address_type          = "ipv4"
    }
  }

  default_cache_behavior {
    target_origin_id = "origin.securanova.net-mu3vopkk883"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront.arn

    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "SecuraNova"
  }

  retain_on_delete = true
}
