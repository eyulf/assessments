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
