### Application

resource "aws_codedeploy_app" "app_2048" {
  name             = "app_2048"
  compute_platform = "ECS"
}

### Deployment Group

resource "aws_codedeploy_deployment_group" "app_2048" {
  app_name               = aws_codedeploy_app.app_2048.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "app_2048"
  service_role_arn       = aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = module.ecs.cluster_name
    service_name = aws_ecs_service.main.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.ecs_http.arn]
      }

      target_group {
        name = aws_lb_target_group.app_2048_blue.name
      }

      target_group {
        name = aws_lb_target_group.app_2048_green.name
      }
    }
  }
}
