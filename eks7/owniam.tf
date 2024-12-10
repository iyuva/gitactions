
data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  
  arn = try(data.aws_caller_identity.current.arn, "")
}

locals {
  # create = var.create 

  #partition = try(data.aws_partition.current[0].partition, "")

  cluster_role = try(aws_iam_role.eks_role.arn, var.iam_role_arn)

  
}

resource "aws_eks_cluster" "this" {
  # count = local.create ? 1 : 0

  name                          = var.cluster_name
  role_arn                      = local.cluster_role #var.cluster_role_arn
  version                       = var.cluster_version
  enabled_cluster_log_types     = var.cluster_enabled_log_types
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons

  access_config {
    authentication_mode = var.authentication_mode

    bootstrap_cluster_creator_admin_permissions = false
  }

  # Compute Config (Node Pools)
#   dynamic "compute_config" {
#     for_each = var.node_pool_config != null ? [1] : []
#     content {
#       enabled       = var.node_pool_config.enabled
#       node_pools    = var.node_pool_config.node_pools
#       node_role_arn = var.node_pool_config.node_role_arn
#     }
#   }

  # VPC Configuration
  vpc_config {
    security_group_ids      = var.security_group_ids
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # Kubernetes Network Configuration
#   dynamic "kubernetes_network_config" {
#     for_each = var.cluster_network_config != null ? [1] : []
#     content {
#       dynamic "elastic_load_balancing" {
#         for_each = var.cluster_network_config.elastic_load_balancing != null ? [1] : []
#         content {
#           enabled = var.cluster_network_config.elastic_load_balancing.enabled
#         }
#       }

#       ip_family         = var.cluster_ip_family
#       service_ipv4_cidr = var.cluster_service_ipv4_cidr
#       #service_ipv6_cidr = var.cluster_service_ipv6_cidr
#     }
#   }
dynamic "kubernetes_network_config" {
  for_each = var.cluster_network_config != null ? [1] : []
  content {
    dynamic "elastic_load_balancing" {
      for_each = var.cluster_network_config.elastic_load_balancing != null && 
                 var.cluster_network_config.elastic_load_balancing.enabled != null ? [1] : []
      content {
        # Explicitly set 'enabled' to true or false based on the value in the config
        enabled = var.cluster_network_config.elastic_load_balancing.enabled
      }
    }

    ip_family         = var.cluster_ip_family
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
    #service_ipv6_cidr = var.cluster_service_ipv6_cidr  # Uncomment if needed
  }
}

  # Outpost Config (Optional)
#   dynamic "outpost_config" {
#     for_each = var.outpost_config != null ? [1] : []
#     content {
#       control_plane_instance_type = var.outpost_config.control_plane_instance_type
#       outpost_arns                = var.outpost_config.outpost_arns
#     }
#   }

  # Encryption Config (Optional)
  dynamic "encryption_config" {
    for_each = var.encryption_config != null ? [1] : []
    content {
      provider {
        key_arn = var.encryption_config.key_arn
      }
      resources = var.encryption_config.resources
    }
  }

  # Remote Network Config (Optional)
  dynamic "remote_network_config" {
    for_each = var.remote_network_config != null ? [1] : []
    content {
      dynamic "remote_node_networks" {
        for_each = var.remote_network_config.remote_node_networks != null ? [1] : []
        content {
          cidrs = var.remote_network_config.remote_node_networks
        }
      }

      dynamic "remote_pod_networks" {
        for_each = var.remote_network_config.remote_pod_networks != null ? [1] : []
        content {
          cidrs = var.remote_network_config.remote_pod_networks
        }
      }
    }
  }

  # Storage Config (Optional)
  dynamic "storage_config" {
    for_each = var.storage_config != null ? [1] : []
    content {
      block_storage {
        enabled = var.storage_config.enabled
      }
    }
  }

  # Upgrade Policy
  dynamic "upgrade_policy" {
    for_each = var.upgrade_policy != null ? [1] : []
    content {
      support_type = var.upgrade_policy.support_type
    }
  }

  # Zonal Shift Config (Optional)
  dynamic "zonal_shift_config" {
    for_each = var.zonal_shift_config != null ? [1] : []
    content {
      enabled = var.zonal_shift_config.enabled
    }
  }

  tags = merge(
    { terraform-aws-modules = "eks" },
    var.tags,
    var.cluster_tags,
  )

  timeouts {
    create = try(var.cluster_timeouts.create, null)
    update = try(var.cluster_timeouts.update, null)
    delete = try(var.cluster_timeouts.delete, null)
  }

  depends_on = [
    # aws_iam_role_policy_attachment.this,
    # aws_iam_policy.cni_ipv6_policy,
    # Optional: Add any additional dependencies
    aws_iam_role_policy_attachment.eks_role_policy_attachments,  # Ensure role policy attachment is completed before cluster creation
    aws_iam_policy.eks_policy,
    aws_iam_policy.eks_permission_boundary
  ]

  lifecycle {
    ignore_changes = [
      access_config[0].bootstrap_cluster_creator_admin_permissions
    ]
  }
}





##############
## IAM 
############

# 1. Create the IAM Policy for EKS Cluster
resource "aws_iam_policy" "eks_policy" {
  name        = "eks-cluster-policy-${var.cluster_name}"
  description = "IAM policy to allow EKS operations"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeAvailabilityZones"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ec2:*:*:security-group/*",
          "arn:aws:ec2:*:*:subnet/*",
          "arn:aws:ec2:*:*:vpc/*",
          "arn:aws:ec2:*:*:availability-zone/*"
        ]
      },
      {
        Action = [
          "iam:ListRolePolicies",
          "iam:GetRole",
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:iam::*:role/eks-*",
          "arn:aws:iam::*:role/aws-service-role/eks.amazonaws.com/*"
        ]
      },
      {
        Action = [
          "cloudwatch:DescribeAlarms",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/eks/*",
          "arn:aws:logs:*:*:log-group:/aws/cloudwatch/*"
        ]
      },
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeAutoScalingInstances"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/*",
          "arn:aws:autoscaling:*:*:launchConfiguration/*"
        ]
      },
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:CreateCluster",
          "eks:DeleteCluster"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:eks:*:*:cluster/${var.cluster_name}"
        ]
      },
      {
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::*:role/aws-service-role/eks.amazonaws.com/*"
      }
    ]
  })
}

# data "aws_account_id" "current" {}
# data "aws_region" "current" {}

resource "aws_iam_policy" "eks_permission_boundary" {
  name        = "eks-cluster-permission-boundary-${var.cluster_name}"
  description = "Permission Boundary for EKS Cluster role"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "eks:*"
        Effect   = "Allow"
        Resource = [
          "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}",
          #"arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:nodegroup/${var.cluster_name}-nodegroup-*"
        ]
      },
      {
        Action   = "ec2:*"
        Effect   = "Allow"
        Resource = [
          #"arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:vpc/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"
        ]
      }
    ]
  })
}


# 3. Create the IAM Role for EKS Cluster with Permission Boundary
resource "aws_iam_role" "eks_role" {
  name               = "eks-cluster-role-${var.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  permissions_boundary = aws_iam_policy.eks_permission_boundary.arn
}

# 4. Attach the IAM Policy to the EKS Role
resource "aws_iam_role_policy_attachment" "eks_role_policy_attachments" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.eks_policy.arn

  depends_on = [
    aws_iam_role.eks_role,
    aws_iam_policy.eks_policy
  ]
}
