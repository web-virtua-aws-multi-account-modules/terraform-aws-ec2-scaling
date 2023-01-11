locals {
  metrics_alarms_up = flatten([
    for item in var.cloudwatch_metrics_alarms : [item.is_scaling_up ? [
      {
        alarm_name          = item.alarm_name != null ? item.alarm_name : "${var.name}-${item.scaling_type == "cpu" ? "cpu" : "memory"}-scale-up"
        alarm_description   = item.alarm_description != null ? item.alarm_description : "Default alarm: ${var.name}-${item.scaling_type == "cpu" ? "cpu" : "memory"}-scale-up"
        comparison_operator = item.comparison_operator
        namespace           = item.namespace
        metric_name         = item.metric_name != null ? item.metric_name : item.scaling_type == "cpu" ? "CPUUtilization" : "MemoryUtilization"
        threshold           = item.threshold != null ? item.threshold : 70
        evaluation_periods  = item.evaluation_periods != null ? item.evaluation_periods : 2
        period              = item.period != null ? item.period : 120
        statistic           = item.statistic
      }] : []
    ]
  ])

  metrics_alarms_down = flatten([
    for item in var.cloudwatch_metrics_alarms : [!item.is_scaling_up ? [
      {
        alarm_name          = item.alarm_name != null ? item.alarm_name : "${var.name}-${item.scaling_type == "cpu" ? "cpu" : "memory"}-scale-down"
        alarm_description   = item.alarm_description != null ? item.alarm_description : "Default alarm: ${var.name}-${item.scaling_type == "cpu" ? "cpu" : "memory"}-scale-down"
        comparison_operator = item.comparison_operator
        namespace           = item.namespace
        metric_name         = item.metric_name != null ? item.metric_name : item.scaling_type == "cpu" ? "CPUUtilization" : "MemoryUtilization"
        threshold           = item.threshold != null ? item.threshold : 20
        evaluation_periods  = item.evaluation_periods != null ? item.evaluation_periods : 2
        period              = item.period != null ? item.period : 120
        statistic           = item.statistic
      }] : []
    ]
  ])
}

resource "aws_autoscaling_policy" "create_policy_up" {
  count = length(local.metrics_alarms_up)

  name                   = local.metrics_alarms_up[count.index].alarm_name
  scaling_adjustment     = var.scaling_adjustment_up
  adjustment_type        = var.adjustment_type_up
  cooldown               = var.cooldown_up
  policy_type            = var.policy_type_up
  autoscaling_group_name = aws_autoscaling_group.create_autoscaling_group.name
}

resource "aws_autoscaling_policy" "create_policy_down" {
  count = length(local.metrics_alarms_down)

  name                   = local.metrics_alarms_down[count.index].alarm_name
  scaling_adjustment     = var.scaling_adjustment_down
  adjustment_type        = var.adjustment_type_down
  cooldown               = var.cooldown_down
  policy_type            = var.policy_type_down
  autoscaling_group_name = aws_autoscaling_group.create_autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "create_alarm_scale_up" {
  count = length(local.metrics_alarms_up)

  alarm_name          = local.metrics_alarms_up[count.index].alarm_name
  alarm_description   = local.metrics_alarms_up[count.index].alarm_description
  comparison_operator = local.metrics_alarms_up[count.index].comparison_operator
  namespace           = local.metrics_alarms_up[count.index].namespace
  metric_name         = local.metrics_alarms_up[count.index].metric_name
  threshold           = local.metrics_alarms_up[count.index].threshold
  evaluation_periods  = local.metrics_alarms_up[count.index].evaluation_periods
  period              = local.metrics_alarms_up[count.index].period
  statistic           = local.metrics_alarms_up[count.index].statistic

  alarm_actions = [
    aws_autoscaling_policy.create_policy_up[count.index].arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.create_autoscaling_group.name
  }
}

resource "aws_cloudwatch_metric_alarm" "create_alarm_scale_down" {
  count = length(local.metrics_alarms_down)

  alarm_name          = local.metrics_alarms_down[count.index].alarm_name
  alarm_description   = local.metrics_alarms_down[count.index].alarm_description
  comparison_operator = local.metrics_alarms_down[count.index].comparison_operator
  namespace           = local.metrics_alarms_down[count.index].namespace
  metric_name         = local.metrics_alarms_down[count.index].metric_name
  threshold           = local.metrics_alarms_down[count.index].threshold
  evaluation_periods  = local.metrics_alarms_down[count.index].evaluation_periods
  period              = local.metrics_alarms_down[count.index].period
  statistic           = local.metrics_alarms_down[count.index].statistic

  alarm_actions = [
    aws_autoscaling_policy.create_policy_down[count.index].arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.create_autoscaling_group.name
  }
}
