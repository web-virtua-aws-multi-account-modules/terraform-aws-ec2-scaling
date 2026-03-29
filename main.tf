locals {
  tags_default = {
    "Name"   = var.name
    "tf-asg" = var.name
    "tf-ou"  = var.ou_name
  }
}

resource "aws_launch_template" "create_launch_template" {
  count = var.launch_template_id_existing == null ? 1 : 0

  name_prefix   = var.name_launch_template != null ? var.name_launch_template : "${var.name}-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  user_data     = var.data_startup_script != null ? base64encode(var.data_startup_script) : null

  monitoring {
    enabled = var.enable_monitoring
  }

  iam_instance_profile {
    name = var.iam_instance_profile_name != null ? var.iam_instance_profile_name : try(aws_iam_instance_profile.create_ec2_profile[0].name, null)
  }

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
  }

  dynamic "instance_market_options" {
    for_each = var.spot_price != null ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price = var.spot_price
      }
    }
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.security_group_ids
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      encrypted             = var.root_encrypted
      iops                  = var.root_iops
      throughput            = var.root_throughput
      delete_on_termination = var.root_delete_on_termination
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.ebs_volume_size != null ? [1] : []
    content {
      device_name = var.ebs_device_name

      ebs {
        volume_size           = var.ebs_volume_size
        volume_type           = var.ebs_volume_type
        encrypted             = var.ebs_encrypted
        iops                  = var.ebs_iops
        throughput            = var.ebs_throughput
        snapshot_id           = var.ebs_snapshot_id
        delete_on_termination = var.ebs_delete_on_termination
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, var.use_tags_default ? local.tags_default : {})
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, var.use_tags_default ? local.tags_default : {})
  }

  lifecycle {
    create_before_destroy = true
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
  placement_group           = try(aws_placement_group.create_placement_group[0].id, null)
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  metrics_granularity       = var.metrics_granularity
  enabled_metrics           = var.enabled_metrics
  capacity_rebalance        = var.capacity_rebalance
  default_cooldown          = var.default_cooldown
  termination_policies      = var.termination_policies
  max_instance_lifetime     = var.max_instance_lifetime

  launch_template {
    id      = var.launch_template_id_existing != null ? var.launch_template_id_existing : aws_launch_template.create_launch_template[0].id
    version = var.launch_template_version
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = merge(var.tags, var.use_tags_default ? { "tf-asg" = var.name, "tf-ou" = var.ou_name } : {})
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
