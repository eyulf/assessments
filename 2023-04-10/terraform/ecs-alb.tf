### Load Balancer

resource "aws_lb" "ecs_alb" {
  name = local.environment

  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.ecs_alb.id]
  subnets            = module.networking.public_subnets

  idle_timeout                     = 3600
  enable_cross_zone_load_balancing = false
  enable_deletion_protection       = true
  enable_http2                     = true
  ip_address_type                  = "ipv4"
  drop_invalid_header_fields       = true

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  #checkov:skip=CKV_AWS_91:TODO Enable Access Logging
  #checkov:skip=CKV2_AWS_20:TODO Configure Proper Domain with ACM and TLSv1.2
  #checkov:skip=CKV2_AWS_28:WAF not required due to CloudFront
}

resource "aws_lb_listener" "ecs_http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }

  lifecycle {
    ignore_changes = [
      default_action["target_group_arn"]
    ]
  }

  #checkov:skip=CKV_AWS_2:TODO Configure Proper Domain with ACM and TLSv1.2
  #checkov:skip=CKV_AWS_103:TODO Configure Proper Domain with ACM and TLSv1.2
}

### Security Group

resource "aws_security_group" "ecs_alb" {
  name        = "${local.environment}-ecs-alb"
  description = "Security group for ${local.environment} ECS ALB"
  vpc_id      = module.networking.vpc_id

  tags = {
    Name = "${local.environment}-ecs-alb"
  }
}

resource "aws_security_group_rule" "ecs_alb_cloudfront_http_in" {
  description       = "HTTP in from CloudFront"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = data.aws_ip_ranges.cloudfront.cidr_blocks
  ipv6_cidr_blocks  = data.aws_ip_ranges.cloudfront.ipv6_cidr_blocks
  security_group_id = aws_security_group.ecs_alb.id
}

resource "aws_security_group_rule" "ecs_alb_app_2048_http_out" {
  description              = "HTTP outbound to ${local.environment}-app_2048"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_2048.id
  security_group_id        = aws_security_group.ecs_alb.id
}
