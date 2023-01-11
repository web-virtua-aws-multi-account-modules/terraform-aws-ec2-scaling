resource "aws_iam_policy" "create_ec2_policy" {
  count = (var.ec2_permission_policy != null && var.iam_instance_profile_name == null) ? 1 : 0

  name        = "${var.name}-ec2-policy"
  path        = var.ec2_policy_path
  description = "Policy to provide permission to EC2"

  policy = jsonencode(var.ec2_permission_policy)
}

resource "aws_iam_role" "create_ec2_role" {
  count = (var.ec2_permission_policy != null && var.iam_instance_profile_name == null) ? 1 : 0

  name               = "${var.name}-ec2-role"
  assume_role_policy = jsonencode(var.ec2_assume_role)
}

resource "aws_iam_policy_attachment" "create_ec2_attachment_policy_role" {
  count = (var.ec2_permission_policy != null && var.iam_instance_profile_name == null) ? 1 : 0

  name       = "${var.name}-ec2-attachment"
  roles      = [aws_iam_role.create_ec2_role[0].name]
  policy_arn = aws_iam_policy.create_ec2_policy[0].arn
}

resource "aws_iam_instance_profile" "create_ec2_profile" {
  count = (var.ec2_permission_policy != null && var.iam_instance_profile_name == null) ? 1 : 0

  name = "${var.name}-ec2-profile"
  role = aws_iam_role.create_ec2_role[0].name
}
