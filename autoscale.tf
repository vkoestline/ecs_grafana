# A CloudWatch alarm that moniors CPU utilization of containers for scaling up
resource "aws_cloudwatch_metric_alarm" "grafana_service_cpu_high" {
  alarm_name = "${var.prefix}-${aws_ecs_service.grafana-service.name}-cpu-utilization-above-80"
  alarm_description = "This alarm monitors ${aws_ecs_service.grafana-service.name} CPU utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "120"
  statistic = "Average"
  threshold = "80"
  alarm_actions = ["${aws_appautoscaling_policy.scale_up.arn}"]

  dimensions {
    ClusterName = "${var.ecs_cluster_name}"
    ServiceName = "${aws_ecs_service.grafana-service.name}"
  }
}

# A CloudWatch alarm that monitors CPU utilization of containers for scaling down
resource "aws_cloudwatch_metric_alarm" "grafana_service_cpu_low" {
  alarm_name = "${var.prefix}-${aws_ecs_service.grafana-service.name}-cpu-utilization-below-5"
  alarm_description = "This alarm monitors ${aws_ecs_service.grafana-service.name} CPU utilization for scaling down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "120"
  statistic = "Average"
  threshold = "5"
  alarm_actions = ["${aws_appautoscaling_policy.scale_down.arn}"]

  dimensions {
    ClusterName = "${var.ecs_cluster_name}"
    ServiceName = "${aws_ecs_service.grafana-service.name}"
  }
}

# A CloudWatch alarm that monitors memory utilization of containers for scaling up
resource "aws_cloudwatch_metric_alarm" "grafana_service_memory_high" {
  alarm_name = "${var.prefix}-${aws_ecs_service.grafana-service.name}-memory-utilization-above-80"
  alarm_description = "This alarm monitors ${aws_ecs_service.grafana-service.name} memory utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "MemoryUtilization"
  namespace = "AWS/ECS"
  period = "120"
  statistic = "Average"
  threshold = "80"
  alarm_actions = ["${aws_appautoscaling_policy.scale_up.arn}"]

  dimensions {
    ClusterName = "${var.ecs_cluster_name}"
    ServiceName = "${aws_ecs_service.grafana-service.name}"
  }
}

# A CloudWatch alarm that monitors memory utilization of containers for scaling down
resource "aws_cloudwatch_metric_alarm" "grafana_service_memory_low" {
  alarm_name = "${var.prefix}-${aws_ecs_service.grafana-service.name}-memory-utilization-below-5"
  alarm_description = "This alarm monitors ${aws_ecs_service.grafana-service.name} memory utilization for scaling down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "MemoryUtilization"
  namespace = "AWS/ECS"
  period = "120"
  statistic = "Average"
  threshold = "5"
  alarm_actions = ["${aws_appautoscaling_policy.scale_down.arn}"]

  dimensions {
    ClusterName = "${var.ecs_cluster_name}"
    ServiceName = "${aws_ecs_service.grafana-service.name}"
  }
}

# --------------------------------------
# ECS policy
# --------------------------------------
resource "aws_iam_role" "autoscale_service_role" {
  name = "${var.prefix}-ecsAutoscaleRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-autoscale-policy" {
  role       = "${aws_iam_role.autoscale_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_appautoscaling_target" "target" {
  resource_id = "service/${var.ecs_cluster_name}/${aws_ecs_service.grafana-service.name}"
  role_arn = "${aws_iam_role.autoscale_service_role.arn}"
  min_capacity = "${var.grafana_scale_min_capacity}"
  max_capacity = "${var.grafana_scale_max_capacity}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name = "${var.prefix}-${aws_ecs_service.grafana-service.name}-scale-up"
  resource_id = "service/${var.ecs_cluster_name}/${aws_ecs_service.grafana-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"

  step_scaling_policy_configuration {
    metric_aggregation_type = "Average"
    cooldown = 120
    adjustment_type = "ChangeInCapacity"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 1
    }
  }
  depends_on = ["aws_appautoscaling_target.target"]
}

resource "aws_appautoscaling_policy" "scale_down" {
  name = "${var.prefix}-${aws_ecs_service.grafana-service.name}-scale-down"
  resource_id = "service/${var.ecs_cluster_name}/${aws_ecs_service.grafana-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"

  step_scaling_policy_configuration {
    metric_aggregation_type = "Average"
    cooldown = 120
    adjustment_type = "ChangeInCapacity"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}
