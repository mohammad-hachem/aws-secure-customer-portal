resource "aws_autoscaling_policy" "app_cpu_target" {
  name                   = "aws-secure-portal-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = 60

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = 30
    disable_scale_in = false
  }
}
