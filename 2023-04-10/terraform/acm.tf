# Local Region

resource "aws_acm_certificate" "main" {
  domain_name               = "${local.environment}.${local.zone}"
  subject_alternative_names = ["*.${local.environment}.${local.zone}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id

  depends_on = [aws_acm_certificate.main]
}

resource "aws_acm_certificate_validation" "acm" {
  certificate_arn = aws_acm_certificate.main.arn

  depends_on = [
    aws_route53_zone.main,
    aws_route53_record.acm
  ]
}

# CloudFront

resource "aws_acm_certificate" "cloudfront" {
  provider = aws.global

  domain_name               = "${local.environment}.${local.zone}"
  subject_alternative_names = ["*.${local.environment}.${local.zone}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_cloudfront" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id

  depends_on = [aws_acm_certificate.cloudfront]
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.global

  certificate_arn = aws_acm_certificate.cloudfront.arn

  depends_on = [
    aws_route53_zone.main,
    aws_route53_record.acm_cloudfront
  ]
}
