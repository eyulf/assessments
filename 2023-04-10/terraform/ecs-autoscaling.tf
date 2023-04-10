resource "aws_appautoscaling_target" "app_2048" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${module.ecs.cluster_name}/${aws_ecs_service.app_2048.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "app_2048" {
  name               = "${local.environment}-2048-target-tracking-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.app_2048.resource_id
  scalable_dimension = aws_appautoscaling_target.app_2048.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app_2048.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 85
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
