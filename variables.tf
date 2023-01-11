###################################################
############### Auto Scaling Group ################
variable "name" {
  description = "Name for auto scalling"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet ID's"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired capacity of the instances"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Min capacity of the instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Max capacity of the instances"
  type        = number
  default     = 1
}

variable "force_delete" {
  description = "Force delete when terminated instances"
  type        = bool
  default     = true
}

variable "health_check_type" {
  description = "Health checking type, can be EC2 or ELB. When using ELB as the health_check_type, health_check_grace_period is required"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Define a period to health check"
  type        = number
  default     = 300
}

variable "target_group_arns" {
  description = "Target groups ARN's"
  type        = list(string)
  default     = null
}

variable "launch_configuration_name_existing" {
  description = "Launch configuration name, if defined will be used on autoscaling group else will be created a new"
  type        = string
  default     = null
}

variable "placement_group" {
  description = "AWS placement group to create instances"
  type = object({
    name     = string
    strategy = string
  })
  default = null
}

variable "wait_for_capacity_timeout" {
  description = "Time to waiting capacity"
  type        = string
  default     = "5m"
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect, by default is 1Minute"
  type        = string
  default     = "1Minute"
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances"
  type        = list(string)
  default     = null
}

variable "capacity_rebalance" {
  description = "Define if will have capacity to rebalance"
  type        = bool
  default     = false
}

variable "default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  type        = string
  default     = null
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated, the allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy and Default"
  type        = list(string)
  default = [
    "Default"
  ]
}

variable "max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 86400 and 31536000 seconds"
  type        = number
  default     = null
}

variable "ou_name" {
  description = "Organization unit name"
  type        = string
  default     = "no"
}

variable "use_tags_default" {
  description = "If true will be use the tags default to instance, volume and elastic IP"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to EC2 instance autoscaling"
  type        = map(any)
  default     = {}
}

#######################################
# Autoscaling Policy
#######################################
variable "name_autoscaling_policy_up" {
  description = "Name for auto scalling UP"
  type        = string
  default     = null
}

variable "name_autoscaling_policy_down" {
  description = "Name for auto scalling DOWN"
  type        = string
  default     = null
}

variable "scaling_adjustment_up" {
  description = "Scaling adjustment up"
  type        = number
  default     = 1
}

variable "scaling_adjustment_down" {
  description = "Scaling adjustment down"
  type        = number
  default     = -1
}

variable "adjustment_type_up" {
  description = "Adjustment type up"
  type        = string
  default     = "ChangeInCapacity"
}

variable "adjustment_type_down" {
  description = "Adjustment type down"
  type        = string
  default     = "ChangeInCapacity"
}

variable "cooldown_up" {
  description = "Cooldown up"
  type        = number
  default     = 300
}

variable "cooldown_down" {
  description = "Cooldown down"
  type        = number
  default     = 300
}

variable "policy_type_up" {
  description = "Policy type UP"
  type        = string
  default     = "SimpleScaling"
}

variable "policy_type_down" {
  description = "Policy type down"
  type        = string
  default     = "SimpleScaling"
}

variable "cloudwatch_metrics_alarms" {
  description = "Define the metrics and alarmes for autoscaling, by default implements scaling up from 70% to CPU and 70% to memory and scaling down from 20% CPU and 20% to memory"
  type = list(object({
    scaling_type        = optional(string, "cpu")
    is_scaling_up       = optional(bool, true)
    alarm_name          = optional(string)
    alarm_description   = optional(string, null)
    comparison_operator = optional(string, "GreaterThanOrEqualToThreshold")
    namespace           = optional(string, "AWS/EC2")
    metric_name         = optional(string, "CPUUtilization")
    threshold           = optional(number, null)
    evaluation_periods  = optional(number, null)
    period              = optional(number, null)
    statistic           = optional(string, "Average")
  }))
  default = [
    {
      scaling_type        = "cpu"
      is_scaling_up       = true
      alarm_description   = "Monitors CPU utilization to up scaling"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name         = "CPUUtilization"
    },
    {
      scaling_type        = "cpu"
      is_scaling_up       = false
      alarm_description   = "Monitors CPU utilization to down scaling"
      comparison_operator = "LessThanOrEqualToThreshold"
      metric_name         = "CPUUtilization"
    },
    {
      scaling_type        = "memory"
      is_scaling_up       = true
      alarm_description   = "Monitors memory utilization to up scaling"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      metric_name         = "MemoryUtilization"
    },
    {
      scaling_type        = "memory"
      is_scaling_up       = false
      alarm_description   = "Monitors memory utilization to down scaling"
      comparison_operator = "LessThanOrEqualToThreshold"
      metric_name         = "MemoryUtilization"
    },
  ]
}

#######################################
# Launch Configuration
#######################################
variable "ami" {
  description = "AMI Instance type"
  type        = string
}
variable "name_launch_config" {
  description = "Name to launch config"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "ID's of the security groups"
  type        = list(string)
  default     = null
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Key Pair to Access SSH"
  type        = string
  default     = null
}

variable "data_startup_script" {
  description = "Shell script to run when starting instance"
  type        = string
  default     = null
}

variable "spot_price" {
  description = "The maximum price to request on the spot market. Defaults to on-demand price, exemple value 0.018"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "If true will be associate a public IP to instance"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "The name of the existing IAM profile to attach to the instance granting permissions to the instance, if null this module will allow creating the IAM profile or not defining any profile"
  type        = string
  default     = null
}

#######################################
# Volume configuration
#######################################
variable "root_volume_size" {
  description = "Size to root volume"
  type        = number
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_encrypted" {
  description = "Root volume encrypted"
  type        = bool
  default     = false
}

variable "root_iops" {
  description = "Root volume IOPS"
  type        = number
  default     = 3000
}

variable "root_throughput" {
  description = "Root volume throughput"
  type        = number
  default     = 125
}

variable "root_delete_on_termination" {
  description = "Root volume termination"
  type        = bool
  default     = true
}

variable "ebs_volume_size" {
  description = "Size to volume device EBS"
  type        = number
  default     = null
}

variable "ebs_volume_type" {
  description = "Type to volume device EBS"
  type        = string
  default     = "gp3"
}

variable "ebs_device_name" {
  description = "Name to source volume device EBS"
  type        = string
  default     = "/dev/sda2"
}

variable "ebs_encrypted" {
  description = "Encryption to EBS"
  type        = bool
  default     = false
}

variable "ebs_iops" {
  description = "IOPS to EBS"
  type        = number
  default     = 3000
}

variable "ebs_throughput" {
  description = "Throughput to EBS"
  type        = number
  default     = 125
}

variable "ebs_snapshot_id" {
  description = "Snapshot ID to EBS"
  type        = string
  default     = null
}

variable "ebs_delete_on_termination" {
  description = "EBS termination"
  type        = bool
  default     = true
}

#######################################
# Role and policy configuration
#######################################
variable "ec2_policy_path" {
  description = "Path to EC2 policy"
  type        = string
  default     = "/"
}

variable "ec2_permission_policy" {
  description = "Policy with the permissions to EC2, should be fomated as json"
  type        = any
  default     = null
}

variable "ec2_assume_role" {
  description = "Assume role to EC2"
  type        = any
  default = {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Sid" : ""
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
      }
    ]
  }
}
