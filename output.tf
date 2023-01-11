output "launch_configuration" {
  description = "Launch configuration"
  value       = try(aws_launch_configuration.create_launch_config[0], null)
}

output "launch_configuration_arn" {
  description = "Launch configuration ARN"
  value       = try(aws_launch_configuration.create_launch_config[0].arn, null)
}

output "placement_group" {
  description = "Placement group"
  value       = try(aws_placement_group.create_placement_group[0], null)
}

output "autoscaling_group" {
  description = "Autoscaling group"
  value       = try(aws_autoscaling_group.create_autoscaling_group, null)
}

output "autoscaling_policy_up" {
  description = "Autoscaling policy UP"
  value       = try(aws_autoscaling_policy.create_policy_up, null)
}

output "autoscaling_policy_down" {
  description = "Autoscaling policy down"
  value       = try(aws_autoscaling_policy.create_policy_down, null)
}

output "alarms_scale_up" {
  description = "Autoscaling policy down"
  value       = try(aws_cloudwatch_metric_alarm.create_alarm_scale_up, null)
}

output "alarms_scale_down" {
  description = "Autoscaling policy down"
  value       = try(aws_cloudwatch_metric_alarm.create_alarm_scale_down, null)
}

output "ec2_policy" {
  description = "EC2 policy"
  value       = try(aws_iam_policy.create_ec2_policy[0], null)
}

output "ec2_role" {
  description = "EC2 role"
  value       = try(aws_iam_role.create_ec2_role[0], null)
}

output "ec2_attachment_policy_role" {
  description = "EC2 attachment policy role"
  value       = try(aws_iam_policy_attachment.create_ec2_attachment_policy_role[0], null)
}

output "ec2_profile" {
  description = "EC2 profile"
  value       = try(aws_iam_instance_profile.create_ec2_profile[0], null)
}

output "metrics_alarms" {
  description = "EC2 metrics_alarms"
  # value       = local.metrics_alarms
  value = [
    length(local.metrics_alarms_up),
    length(local.metrics_alarms_down),
    local.metrics_alarms_up,
    local.metrics_alarms_down
  ]
}
