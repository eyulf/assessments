resource "aws_route53_zone" "main" {
  name    = "${local.environment}.${local.zone}"
  comment = "${local.environment} zone for ${local.zone}"
}
