locals {
  tags_default = {
    "Name"   = var.name
    "tf-asg" = var.name
    "tf-ou"  = var.ou_name
  }

  asg_tags = merge(
    { "Name" = var.name },
    { "tf-asg" = var.name },
    { "tf-ou" = var.name }
  )
}

resource "aws_launch_configuration" "create_launch_config" {
  count = var.launch_configuration_name_existing == null ? 1 : 0

  name_prefix                 = var.name_launch_config != null ? var.name_launch_config : "${var.name}-launch-config"
  image_id                    = var.ami
  security_groups             = var.security_group_ids
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  user_data                   = var.data_startup_script
  spot_price                  = var.spot_price
  associate_public_ip_address = var.associate_public_ip_address
  enable_monitoring           = var.enable_monitoring
  iam_instance_profile        = var.iam_instance_profile_name != null ? var.iam_instance_profile_name : try(aws_iam_instance_profile.create_ec2_profile[0].name, null)

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_encrypted
    iops                  = var.root_iops
    throughput            = var.root_throughput
    delete_on_termination = var.root_delete_on_termination
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_volume_size != null ? [1] : []
    content {
      volume_size           = var.ebs_volume_size
      device_name           = var.ebs_device_name
      volume_type           = var.ebs_volume_type
      encrypted             = var.ebs_encrypted
      iops                  = var.ebs_iops
      throughput            = var.ebs_throughput
      snapshot_id           = var.ebs_snapshot_id
      delete_on_termination = var.ebs_delete_on_termination
    }
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_placement_group" "create_placement_group" {
  count = var.placement_group != null ? 1 : 0

  name     = var.placement_group.name
  strategy = var.placement_group.strategy
}

resource "aws_autoscaling_group" "create_autoscaling_group" {
  name                      = var.name
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  force_delete              = var.force_delete
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  launch_configuration      = try(aws_launch_configuration.create_launch_config[0].name, var.launch_configuration_name_existing)
  placement_group           = try(aws_placement_group.create_placement_group[0].id, null)
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  metrics_granularity       = var.metrics_granularity
  enabled_metrics           = var.enabled_metrics
  capacity_rebalance        = var.capacity_rebalance
  default_cooldown          = var.default_cooldown
  termination_policies      = var.termination_policies
  max_instance_lifetime     = var.max_instance_lifetime

  dynamic "tag" {
    for_each = merge(var.tags, var.use_tags_default ? local.tags_default : {})
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [load_balancers]
  }
}
