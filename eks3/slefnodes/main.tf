# IAM Instance Profile for EC2 Instances
resource "aws_iam_instance_profile" "self_managed_node_profile" {
  for_each = var.clusters

  name = "${each.value.cluster_name}-node-profile"
  role = aws_iam_role.self_managed_node_role[each.key].name
}

# Placement Group for Worker Nodes (Optional)
resource "aws_placement_group" "self_managed_node_placement_group" {
  for_each = var.clusters

  name     = "${each.value.cluster_name}-placement-group"
  strategy = lookup(var.custom_overrides[each.key], "placement_group_strategy", var.placement_group_strategy)
}

# Launch Template for EC2 Instances
resource "aws_launch_template" "self_managed_node_group" {
  for_each = var.clusters

  name_prefix   = "${each.value.cluster_name}-lt-"
  description   = "Launch template for self-managed nodes for ${each.value.cluster_name}"
  image_id      = lookup(var.custom_overrides[each.key], "node_ami_id", var.node_ami_id)
  instance_type = lookup(var.custom_overrides[each.key], "node_instance_type", var.node_instance_type)

  iam_instance_profile {
    name = aws_iam_instance_profile.self_managed_node_profile[each.key].name
  }

  placement {
    group_name = aws_placement_group.self_managed_node_placement_group[each.key].name
  }

  network_interfaces {
    associate_public_ip_address = var.node_associate_public_ip
    security_groups             = [aws_security_group.self_managed_node_group[each.key].id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        "Name"               = "${each.value.cluster_name}-node",
        "Cluster"            = each.value.cluster_name,
        "eks:nodegroup-name" = "${each.value.cluster_name}-nodegroup"
      }
    )
  }
}

# Autoscaling Group
resource "aws_autoscaling_group" "self_managed_node_group" {
  for_each = var.clusters

  desired_capacity = lookup(var.custom_overrides[each.key], "node_desired_capacity", var.node_desired_capacity)
  max_size         = lookup(var.custom_overrides[each.key], "node_max_size", var.node_max_size)
  min_size         = lookup(var.custom_overrides[each.key], "node_min_size", var.node_min_size)

  launch_template {
    id      = aws_launch_template.self_managed_node_group[each.key].id
    version = "$Latest"
  }

  vpc_zone_identifier = lookup(var.custom_overrides[each.key], "subnet_ids", var.subnet_ids)

  tag {
    key                 = "kubernetes.io/cluster/${each.value.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${each.value.cluster_name}-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.this]
}

# Autoscaling Schedule (Optional)
resource "aws_autoscaling_schedule" "scale_out" {
  for_each = var.clusters

  scheduled_action_name = "${each.value.cluster_name}-scale-out"
  min_size              = lookup(var.scaling_policies[each.key], "scale_out_min", var.schedule_scale_out_min)
  max_size              = lookup(var.scaling_policies[each.key], "scale_out_max", var.schedule_scale_out_max)
  desired_capacity      = lookup(var.scaling_policies[each.key], "scale_out_desired", var.schedule_scale_out_desired)
  recurrence            = var.schedule_scale_out_recurrence

  autoscaling_group_name = aws_autoscaling_group.self_managed_node_group[each.key].name
}

resource "aws_autoscaling_schedule" "scale_in" {
  for_each = var.clusters

  scheduled_action_name = "${each.value.cluster_name}-scale-in"
  min_size              = lookup(var.scaling_policies[each.key], "scale_in_min", var.schedule_scale_in_min)
  max_size              = lookup(var.scaling_policies[each.key], "scale_in_max", var.schedule_scale_in_max)
  desired_capacity      = lookup(var.scaling_policies[each.key], "scale_in_desired", var.schedule_scale_in_desired)
  recurrence            = var.schedule_scale_in_recurrence

  autoscaling_group_name = aws_autoscaling_group.self_managed_node_group[each.key].name
}

# Security Group
resource "aws_security_group" "self_managed_node_group" {
  for_each = var.clusters

  name        = "${each.value.cluster_name}-node-sg"
  description = "Security group for self-managed nodes for ${each.value.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all traffic from cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [
      aws_security_group.this.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${each.value.cluster_name}-node-sg"
    }
  )
}

# IAM Role for Node Group
resource "aws_iam_role" "self_managed_node_role" {
  for_each = var.clusters

  name = "${each.value.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = var.clusters

  role       = aws_iam_role.self_managed_node_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policies" {
  for_each = var.clusters

  role       = aws_iam_role.self_managed_node_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSCNIPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_policies" {
  for_each = var.clusters

  role       = aws_iam_role.self_managed_node_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
