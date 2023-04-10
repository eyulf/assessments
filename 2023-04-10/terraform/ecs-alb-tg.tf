### Target Group

resource "aws_lb_listener_rule" "app_2048" {
  listener_arn = aws_lb_listener.ecs_http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_2048_blue.arn
  }

  condition {
    http_header {
      http_header_name = "X-CloudFront-Auth"
      values           = [random_string.cloudfront_auth.result]
    }
  }

  lifecycle {
    ignore_changes = [
      action["target_group_arn"]
    ]
  }
}

resource "aws_lb_target_group" "app_2048_blue" {
  name     = "app-2048-1"

  target_type = "ip"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = module.networking.vpc_id

  health_check {
    enabled  = true
    interval = 30
    matcher  = "200"
    path     = "/"
    timeout  = 5

    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "app_2048_green" {
  name     = "app-2048-2"

  target_type = "ip"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = module.networking.vpc_id

  health_check {
    enabled  = true
    interval = 30
    matcher  = "200"
    path     = "/"
    timeout  = 5

    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}
