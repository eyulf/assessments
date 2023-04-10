### MetaData

data "aws_ip_ranges" "cloudfront" {
  regions  = ["global"]
  services = ["cloudfront"]
}

resource "aws_servicequotas_service_quota" "rules_per_security_group" {
  quota_code   = "L-0EA8095F"
  service_code = "vpc"
  value        = 125
}

resource "random_string" "cloudfront_auth" {
  length  = 40
  special = false
}

### Cloudfront

data "aws_cloudfront_cache_policy" "app_2048" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "app_2048" {
  name = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_response_headers_policy" "app_2048" {
  name = "Managed-CORS-with-preflight-and-SecurityHeadersPolicy"
}

resource "aws_cloudfront_distribution" "app_2048" {
  comment             = "ECS Application ${local.environment}-2048"
  price_class         = "PriceClass_All"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version        = "http2and3"

  origin {
    origin_id   = "ECS-${local.environment}-2048"
    domain_name = aws_lb.ecs_alb.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "X-CloudFront-Auth"
      value = random_string.cloudfront_auth.result
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ECS-${local.environment}-2048"

    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = data.aws_cloudfront_cache_policy.app_2048.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.app_2048.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.app_2048.id
    compress                   = true
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

output "cloudfront_url" {
  description = "The URL of the Cloudfront Distribution."
  value       = aws_cloudfront_distribution.app_2048.domain_name
}
