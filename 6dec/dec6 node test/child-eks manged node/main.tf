##################################
# IAM Role for EKS Node Group
##################################
resource "aws_iam_role" "eks_node_role" {
  name               = "${var.node_group_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json

}

# Attach necessary managed policies
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  for_each = {
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2FullAccess                = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  }

  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

##################################
# Assume Role Policy Document
##################################
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

##################################
# IAM Policy for EKS Node Group (Custom Permissions)
##################################
resource "aws_iam_policy" "eks_node_policy" {
  name        = "${var.node_group_name}-node-policy"
  description = "IAM policy for EKS worker nodes with minimal permissions"

  # Define permissions explicitly without using "*"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "cloudwatch:PutMetricData",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "eks:DescribeCluster",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "s3:GetObject",
          "s3:ListBucket",
          "cloudwatch:DescribeAlarms",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

##################################
# Attach IAM Policy to Node Role
##################################
resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  policy_arn = aws_iam_policy.eks_node_policy.arn
  role       = aws_iam_role.eks_node_role.name
}

##################################
# EKS Node Group
##################################
resource "aws_eks_node_group" "this" {
  cluster_name  = var.cluster_name               # Referencing the EKS cluster name
  node_role_arn = aws_iam_role.eks_node_role.arn # Using the dynamically created node role
  subnet_ids    = var.subnet_ids                 # List of subnet IDs for the node group

  scaling_config {
    min_size     = var.min_size     # Minimum number of nodes
    max_size     = var.max_size     # Maximum number of nodes
    desired_size = var.desired_size # Desired number of nodes
  }

  # Optional parameters
  node_group_name        = var.node_group_name             # Node group name (from variable)
  node_group_name_prefix = "${var.node_group_name}-prefix" # Optional prefix for the node group

  ami_type        = var.ami_type        # Type of AMI (AL2 or Ubuntu)
  release_version = var.release_version # EKS optimized AMI release version
  version         = var.eks_version     # EKS Kubernetes version for the node group

  capacity_type = var.capacity_type # On-demand or Spot instances
  disk_size     = var.disk_size     # EBS volume size in GB

  # Optional dynamic configurations
  dynamic "launch_template" {
    for_each = var.launch_template ? [1] : [] # Optional: Only use if launch template is set

    content {
      id      = var.launch_template_id
      version = var.launch_template_version
    }
  }

  dynamic "remote_access" {
    for_each = var.remote_access_enabled ? [1] : [] # Enable SSH if needed

    content {
      ec2_ssh_key               = var.ssh_key_name
      source_security_group_ids = var.ssh_security_group_ids
    }
  }

  dynamic "taint" {
    for_each = var.taints # Optional: Only add taints if needed

    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  dynamic "update_config" {
    for_each = var.update_config_enabled ? [1] : [] # Enable custom update config if needed

    content {
      max_unavailable_percentage = var.max_unavailable_percentage
      max_unavailable            = var.max_unavailable
    }
  }

  timeouts {
    create = lookup(var.timeouts, "create", "30m") # Default 30 minutes if not provided
    update = lookup(var.timeouts, "update", "30m") # Default 30 minutes if not provided
    delete = lookup(var.timeouts, "delete", "30m") # Default 30 minutes if not provided
  }

  lifecycle {
    create_before_destroy = true # Ensures node group is recreated before deletion
    ignore_changes = [
      scaling_config[0].desired_size, # Ignore changes to desired_size for auto-scaling
    ]
  }

  tags = merge(
    var.tags,
    { Name = var.node_group_name }
  )
}

##################################
# Autoscaling Group Schedule (Optional)
##################################
resource "aws_autoscaling_schedule" "this" {
  for_each = { for k, v in var.schedules : k => v if var.create && var.create_schedule }

  scheduled_action_name = each.key
  #autoscaling_group_name = aws_eks_node_group.this[0].resources[0].autoscaling_groups[0].name
  autoscaling_group_name = aws_eks_node_group.this.resources[0].autoscaling_groups[0].name


  min_size         = try(each.value.min_size, null)
  max_size         = try(each.value.max_size, null)
  desired_capacity = try(each.value.desired_size, null)
  start_time       = try(each.value.start_time, null)
  end_time         = try(each.value.end_time, null)
  time_zone        = try(each.value.time_zone, null)

  # [Minute] [Hour] [Day_of_Month] [Month_of_Year] [Day_of_Week]
  # Cron examples: https://crontab.guru/examples.html
  recurrence = try(each.value.recurrence, null)
}




############################ security group 

# Define the security group ingress rules in a list
locals {
  ingress_rules = [
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = var.ssh_cidr_blocks }
  ]
}

resource "aws_security_group" "eks_node_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Allow inbound traffic for EKS managed node group"
  vpc_id      = var.vpc_id # Replace with your VPC ID

  # Loop through the ingress rules to create each one
  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Allow all outbound traffic from the node group
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # All traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}





########################################
### aws_ec2_tag
########################################
resource "aws_ec2_tag" "node_group_tags" {
  for_each = toset(var.node_group_tags)

  resource_id = aws_eks_node_group.this.id
  key         = each.key
  value       = each.value
}

variable "node_group_tags" {
  type = map(string)
  default = {
    "Environment" = "production"
    "Owner"       = "team-x"
  }
}
