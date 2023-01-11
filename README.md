# AWS EC2 autoscaling for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of the EC2 autoscaling across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of EC2 autoscaling configurations for this module:

- Autoscaling EC2
- Placement group
- Launch configuration
- Autoscaling policy
- Policy and role to permissions

## Usage exemples


### Create on demand EC2 autoscaling with root volume, SSH access and run instalation script

```hcl
module "vm_elasticsearch_cluster_autoscalling" {
  source = "web-virtua-aws-multi-account-modules/ec2-scaling/aws"

  name                = "tf-test-ec2-scaling"
  ami                 = data.aws_ami.ubuntu_ami.id
  instance_type       = var.t3a_nano
  key_pair_name       = "key-pair-name"
  data_startup_script = file("./shell_files/install_apache.sh")
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3
  force_delete        = true
  health_check_type   = "EC2"
  root_volume_type    = "gp3"
  root_volume_size    = 15
  root_iops           = 3000
  root_throughput     = 125

  target_group_arns   = [
    "arn:aws:elasticloadbalancing:us-east-1:3858..012:targetgroup/tf-alb-acm-records-tg-1/41d3b....120e"
  ]

  security_group_ids = [
    "sg-018620a...764c"
  ]

  subnet_ids = [
    "subnet-0eff3...bde8"
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Create on demand EC2 autoscaling with root volume and EBS additional, SSH access, run instalation script and policy and role to access

```hcl
module "vm_elasticsearch_cluster_autoscalling" {
  source = "web-virtua-aws-multi-account-modules/ec2-scaling/aws"

  name                  = "tf-test-ec2-scaling"
  ami                   = data.aws_ami.ubuntu_ami.id
  instance_type         = var.t3a_nano
  key_pair_name         = "key-pair-name"
  data_startup_script   = file("./shell_files/install_apache.sh")
  ec2_permission_policy = var.ec2_permission_policy
  root_volume_size      = 15
  ebs_volume_size       = 16
  desired_capacity      = 1
  min_size              = 1
  max_size              = 3

  target_group_arns = [
    "arn:aws:elasticloadbalancing:us-east-1:3858..012:targetgroup/tf-alb-acm-records-tg-1/41d3b....120e"
  ]

  security_group_ids = [
    "sg-018620a...764c"
  ]

  subnet_ids = [
    "subnet-0eff3...bde8"
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Create on SPOT EC2 autoscaling with root volume, SSH access and run instalation script

```hcl
module "vm_elasticsearch_cluster_autoscalling" {
  source = "web-virtua-aws-multi-account-modules/ec2-scaling/aws"

  name                  = "tf-test-ec2-scaling"
  ami                   = data.aws_ami.ubuntu_ami.id
  instance_type         = var.t3a_nano
  key_pair_name         = "key-pair-name"
  data_startup_script   = file("./shell_files/install_apache.sh")
  spot_price            = "0.0113"
  root_volume_size      = 15
  desired_capacity      = 1
  min_size              = 1
  max_size              = 3

  target_group_arns = [
    "arn:aws:elasticloadbalancing:us-east-1:3858..012:targetgroup/tf-alb-acm-records-tg-1/41d3b....120e"
  ]

  security_group_ids = [
    "sg-018620a...764c"
  ]

  subnet_ids = [
    "subnet-0eff3...bde8"
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Create on demand EC2 autoscaling with root volume, cloudwatch metrics alarms custom configuration and SSH acces

```hcl
module "vm_elasticsearch_cluster_autoscalling" {
  source = "web-virtua-aws-multi-account-modules/ec2-scaling/aws"

  name                      = "tf-test-ec2-scaling"
  ami                       = data.aws_ami.ubuntu_ami.id
  instance_type             = var.t3a_nano
  key_pair_name             = "key-pair-name"
  cloudwatch_metrics_alarms = var.cloudwatch_metrics_alarms
  root_volume_size          = 15

  target_group_arns = [
    "arn:aws:elasticloadbalancing:us-east-1:3858..012:targetgroup/tf-alb-acm-records-tg-1/41d3b....120e"
  ]

  security_group_ids = [
    "sg-018620a...764c"
  ]

  subnet_ids = [
    "subnet-0eff3...bde8"
  ]

  providers = {
    aws = aws.alias_profile_a
  }
}
```


## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| name | `string` | `-` | yes | Name for auto scalling | `-` |
| subnet_ids | `list(string)` | `-` | yes | Subnet ID's | `-` |
| desired_capacity | `number` | `1` | no | Desired capacity of the instances | `-` |
| min_size | `number` | `1` | no | Min capacity of the instances | `-` |
| max_size | `number` | `1` | no | Max capacity of the instances | `-` |
| force_delete | `bool` | `true` | no | Force delete when terminated instances | `*`false <br> `*`true |
| health_check_type | `string` | `EC2` | no | Health checking type, can be EC2 or ELB. When using ELB as the health_check_type, health_check_grace_period is required | `*`EC2 <br> `*`ELB |
| health_check_grace_period | `number` | `300` | no | Define a period to health check | `-` |
| target_group_arns | `list(string)` | `null` | no | Target groups ARN's | `-` |
| launch_configuration_name_existing | `string` | `null` | no | Launch configuration name, if defined will be used on autoscaling group else will be created a new | `-` |
| placement_group | `object` | `null` | no | AWS placement group to create instances | `-` |
| wait_for_capacity_timeout | `string` | `5m` | no | Time to waiting capacity | `-` |
| metrics_granularity | `string` | `1Minute` | no | The granularity to associate with the metrics to collect, by default is 1Minute | `-` |
| enabled_metrics | `list(string)` | `null` | no | A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances | `-` |
| capacity_rebalance | `bool` | `false` | no | Define if will have capacity to rebalance | `*`false <br> `*`true |
| default_cooldown | `string` | `null` | no | Time between a scaling activity and the succeeding scaling activity | `-` |
| termination_policies | `list(string)` | `["Default"]` | no | A list of policies to decide how the instances in the Auto Scaling Group should be terminated, the allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy and Default | `-` |
| max_instance_lifetime | `number` | `null` | no | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 86400 and 31536000 seconds | `-` |
| ou_name | `string` | `no` | no | Organization unit name | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to instance, volume and elastic IP | `*`false <br> `*`true |
| tags | `map(any)` | `{}` | no | Tags to EC2 instance autoscaling | `-` |
| name_autoscaling_policy_up | `string` | `null` | no | "Name for auto scalling UP | `-` |
| name_autoscaling_policy_down | `string` | `null` | no | Name for auto scalling DOWN" | `-` |
| scaling_adjustment_up | `number` | `1` | no | Scaling adjustment up | `-` |
| scaling_adjustment_down | `number` | `-1` | no | Scaling adjustment down | `-` |
| adjustment_type_up | `string` | `ChangeInCapacity` | no | Adjustment type up | `-` |
| adjustment_type_down | `string` | `ChangeInCapacity` | no | Adjustment type down | `-` |
| cooldown_up | `number` | `300` | no | Cooldown up | `-` |
| cooldown_down | `number` | `300` | no | Cooldown down | `-` |
| policy_type_up | `string` | `null` | no | Policy type up | `-` |
| policy_type_down | `string` | `null` | no | Policy type down | `-` |
| cloudwatch_metrics_alarms | `list(object)` | `object` | no | Define the metrics and alarmes for autoscaling, by default implements scaling up from 70% to CPU and scaling down from 20% CPU | `-` |
| ami | `string` | `-` | yes | AMI Instance type | `-` |
| name_launch_config | `string` | `null` | no | Name to launch config | `-` |
| security_group_ids | `list(string)` | `[]` | no | ID's of the security groups | `-` |
| instance_type | `string` | `t2.micro` | no | Instance type | `-` |
| key_pair_name | `string` | `null` | no | Key Pair to Access SSH | `-` |
| data_startup_script | `string` | `-` | no | Shell script to run when starting instance | `-` |
| spot_price | `string` | `null` | no | The maximum price to request on the spot market. Defaults to on-demand price, exemple value 0.018 | `-` |
| associate_public_ip_address | `bool` | `true` | no | If true will be associate a public IP to instance | `*`false <br> `*`true |
| enable_monitoring | `bool` | `true` | no | Enables/disables detailed monitoring | `*`false <br> `*`true |
| iam_instance_profile_name | `string` | `null` | no | The name of the existing IAM profile to attach to the instance granting permissions to the instance, if null this module will allow creating the IAM profile or not defining any profile | `-` |
| root_volume_size | `number` | `-` | yes | Size to root volume | `-` |
| root_volume_type | `string` | `gp3` | no | Root volume type | `-` |
| root_encrypted | `bool` | `false` | no | Root volume encrypted | `*`false <br> `*`true |
| root_iops | `number` | `3000` | no | Root volume IOPS | `-` |
| root_throughput | `number` | `125` | no | Root volume throughput | `-` |
| root_delete_on_termination | `bool` | `true` | no | Root volume termination | `*`false <br> `*`true |
| ebs_volume_size | `number` | `null` | no | Size to volume device EBS | `-` |
| ebs_volume_type | `string` | `gp3` | no | Type to volume device EBS | `-` |
| ebs_device_name | `string` | `/dev/sda2` | no | Name to source volume device EBS | `-` |
| ebs_encrypted | `bool` | `false` | no | Encryption to EBS | `*`false <br> `*`true |
| ebs_iops | `number` | `3000` | no | IOPS to EBS | `-` |
| ebs_throughput | `number` | `125` | no | Throughput to EBS | `-` |
| ebs_snapshot_id | `string` | `null` | no | Snapshot ID to EBS | `-` |
| ebs_delete_on_termination | `bool` | `true` | no | EBS termination | `*`false <br> `*`true |
| ec2_policy_path | `string` | `/` | no | Path to EC2 policy | `-` |
| ec2_permission_policy | `any` | `null` | no | Policy with the permissions to EC2, should be fomated as json | `-` |
| ec2_assume_role | `any` | `object` | no | Policy with the permissions to EC2, should be fomated as json | `-` |

* Model of variable cloudwatch_metrics_alarms
OBS: By default will be implements scaling up from 70% to CPU and scaling down from 20% CPU, else will be used the the values defined in this variable
```hcl
variable "cloudwatch_metrics_alarms" {
  description = "Define the metrics and alarmes for autoscaling, by default implements scaling up from 70% to CPU and scaling down from 20% CPU"
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
      threshold           = 50
      evaluation_periods  = 2
      period              = 120
    },
    {
      scaling_type        = "cpu"
      is_scaling_up       = false
      alarm_description   = "Monitors CPU utilization to down scaling"
      comparison_operator = "LessThanOrEqualToThreshold"
      metric_name         = "CPUUtilization"
      threshold           = 15
      evaluation_periods  = 2
      period              = 120
    },
  ]
}
```

* Model of variable ec2_permission_policy
```hcl
variable "ec2_permission_policy" {
  description = "Policy with the permissions to EC2"
  type        = any
  default = {
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:Getobject",
          "s3:List*"
        ]
        "Resource" : [
          "*"
        ]
      }
    ]
  }
}
```

* Model of variable placement_group
```hcl
description = "AWS placement group to create instances"
  type = object({
    name     = string
    strategy = string
  })
  default = {
    name     = "the-name"
    strategy = "cluster"
  }
```

## Resources

| Name | Type |
|------|------|
| [aws_launch_configuration.create_launch_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_placement_group.create_placement_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group) | resource |
| [aws_autoscaling_group.create_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.create_policy_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.create_policy_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_metric_alarm.create_alarm_scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.create_alarm_scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.create_ec2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.create_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_attachment.create_ec2_attachment_policy_role](https://registry.terraform.io/providers/hashicorp/aws/3.29.1/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_instance_profile.create_ec2_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `launch_configuration` | Launch configuration |
| `launch_configuration_arn` | Launch configuration ARN |
| `placement_group` | Placement group |
| `autoscaling_group` | Autoscaling group |
| `autoscaling_policy_up` | Autoscaling policy UP |
| `autoscaling_policy_down` | Autoscaling policy down |
| `ec2_policy` | EC2 policy |
| `ec2_role` | EC2 role |
| `ec2_attachment_policy_role` | EC2 attachment policy role |
| `ec2_profile` | EC2 profile |
