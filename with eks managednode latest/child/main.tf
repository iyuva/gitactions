provider "aws" {
  region     = "us-east-1"                                # Adjust to your preferred AWS region
  access_key = "AKIA35X37YJGMYFJO2HZ"                     # Your AWS access key
  secret_key = "18v0U0GUehNOysx+CPHGI+922KvWHfA6ssEPw9hX" # Your AWS secret key
}

#######################
# IAM Resources
#######################

resource "aws_iam_role" "eks_role" {
  name = "eks-${var.cluster_name}-role" # Dynamically generate the role name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  tags = merge(var.default_tags, {
    Name = "eks-${var.cluster_name}-role"
  })
}

resource "aws_iam_policy" "eks_policy" {
  name        = "eks-${var.cluster_name}-policy" # Dynamically generate the policy name
  description = "Policy for managing EKS cluster ${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "eks:UpdateClusterVersion",
          "eks:UpdateClusterConfig",
          "eks:DeleteCluster"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateSecurityGroup",
          "ec2:ModifyInstanceAttribute"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_role_policy_attachment" {
  policy_arn = aws_iam_policy.eks_policy.arn
  role       = aws_iam_role.eks_role.name
}

#######################
# EKS Cluster
#######################

resource "aws_eks_cluster" "eks_cluster" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.eks_role.arn
  version                       = var.cluster_version
  enabled_cluster_log_types     = var.enabled_log_types
  bootstrap_self_managed_addons = var.bootstrap_addons

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.cluster_creator_permissions
  }

  vpc_config {
    security_group_ids      = [aws_security_group.eks_control_planes.id]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    for_each = var.cluster_ip_family != null ? [1] : []
    content {
      ip_family         = var.cluster_ip_family
      service_ipv4_cidr = var.cluster_service_ipv4_cidr
    }
  }

  # dynamic "outpost_config" {
  #   for_each = var.outpost_config != null ? [var.outpost_config] : []
  #   content {
  #     control_plane_instance_type = outpost_config.value.control_plane_instance_type
  #     outpost_arns                = outpost_config.value.outpost_arns
  #   }
  # }

  # dynamic "encryption_config" {
  #   for_each = var.cluster_encryption_config != null ? [var.cluster_encryption_config] : []
  #   content {
  #     provider {
  #       key_arn = var.create_kms_key ? module.kms.key_arn : encryption_config.value.provider_key_arn
  #     }
  #     resources = encryption_config.value.resources
  #   }
  # }

  # upgrade_policy {
  #   support_type = var.cluster_upgrade_policy
  # }

  zonal_shift_config {
    enabled = var.cluster_zonal_shift_enabled
  }

  tags = merge(var.default_tags, {
    ClusterName = var.cluster_name
  })

  timeouts {
    create = var.cluster_timeouts.create
    update = var.cluster_timeouts.update
    delete = var.cluster_timeouts.delete
  }

  depends_on = [aws_iam_role.eks_role]
}

#######################
# Security Groups for EKS Cluster
#######################

resource "aws_security_group" "eks_control_planes" {
  name        = "eks-${var.cluster_name}-control-planes" # Dynamically generate SG name
  description = "Security group for EKS Control Plane"
  vpc_id      = var.vpc_id

  tags = merge(var.default_tags, {
    Name = "eks-${var.cluster_name}-control-planes"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "eks_control_planes_ingress" {
  security_group_id = aws_security_group.eks_control_planes.id
  protocol          = var.security_group_protocol
  from_port         = var.security_group_from_port
  to_port           = var.security_group_to_port
  type              = var.security_group_type
  description       = var.security_group_description
  cidr_blocks       = var.security_group_cidr_blocks
}

#######################
# EC2 Tags for EKS Resources
#######################

resource "aws_ec2_tag" "eks_security_group_tag" {
  resource_id = aws_security_group.eks_control_planes.id
  key         = "Name"
  value       = "eks-${var.cluster_name}-control-planes" # Tag SG with cluster name
}

resource "aws_ec2_tag" "eks_subnet_tag" {
  for_each = toset(var.subnet_ids)

  resource_id = each.value
  key         = "Name"
  value       = "eks-${var.cluster_name}-subnet-${each.key}" # Tag subnets with cluster name and subnet ID
}

#######################
# IAM Roles and Policies for Addons (Optional, Uncomment if Needed)
#######################

# resource "aws_iam_role" "eks_addon_role" {
#   for_each = var.addon_names

#   name = "eks-${var.cluster_name}-${each.value}-role"  # Dynamically generate role name for each addon

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Effect = "Allow"
#       }
#     ]
#   })

#   tags = {
#     Name = "eks-${var.cluster_name}-${each.value}-role"  # Tag the addon role with the cluster and addon name
#   }
# }

# resource "aws_iam_policy" "eks_addon_policy" {
#   for_each = var.addon_names

#   name        = "eks-${var.cluster_name}-${each.value}-policy"  # Dynamically generate policy name for each addon
#   description = "EKS Addon policy for managing pod identity association for ${each.value}"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = "sts:AssumeRole"
#         Effect   = "Allow"
#         Resource = "*"
#       },
#       {
#         Action   = "iam:PassRole"
#         Effect   = "Allow"
#         Resource = aws_iam_role.eks_addon_role[each.key].arn
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_addon_role_attachment" {
#   for_each = var.addon_names

#   policy_arn = aws_iam_policy.eks_addon_policy[each.key].arn
#   role       = aws_iam_role.eks_addon_role[each.key].name
# }

#######################
# EKS Addon Installation (Optional, Uncomment if Needed)
#######################

# resource "aws_eks_addon" "eks_addon" {
#   for_each = var.addon_names

#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   addon_name    = each.value
#   addon_version = var.addon_versions[each.value] # Make sure this is defined in your variables
# }

#######################
# Identity Provider Config (Optional, Uncomment if Needed)
#######################

# resource "aws_eks_identity_provider_config" "eks_identity_provider" {
#   cluster_name = aws_eks_cluster.eks_cluster.name

#   oidc {
#     client_id                     = var.oidc_client_id
#     groups_claim                  = var.oidc_groups_claim
#     groups_prefix                 = var.oidc_groups_prefix
#     identity_provider_config_name = var.oidc_config_name
#     issuer_url                    = var.oidc_issuer_url
#     required_claims               = var.oidc_required_claims
#     username_claim                = var.oidc_username_claim
#     username_prefix               = var.oidc_username_prefix
#   }

#   tags = merge(var.default_tags, var.oidc_tags)
# }

#######################
# EKS Access Entry and Policy Association (Optional, Uncomment if Needed)
#######################

# resource "aws_eks_access_entry" "eks_access_entry" {
#   cluster_name      = aws_eks_cluster.eks_cluster.name
#   kubernetes_groups = var.kubernetes_groups
#   principal_arn     = var.principal_arn
#   type              = var.access_entry_type
#   user_name         = var.user_name

#   tags = merge(var.default_tags, var.access_entry_tags)
# }

# resource "aws_eks_access_policy_association" "eks_access_policy_association" {
#   access_scope {
#     namespaces = var.access_policy_namespaces
#     type       = var.access_policy_type
#   }

#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   policy_arn    = var.access_policy_arn
#   principal_arn = var.access_policy_principal_arn
# }


#######################################################################################################################
# EKS Managed Node Group
###########################################################################################################################

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-${var.cluster_name}-node-group" # Dynamically generated name
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  instance_types = var.node_group_instance_types # A list of instance types for the node group

  remote_access {
    ec2_ssh_key               = var.ssh_key_name # If you want SSH access to the nodes
    source_security_group_ids = [aws_security_group.eks_node_group.id]
  }

  ami_type = var.node_group_ami_type # E.g., AL2_x86_64

  tags = merge(var.default_tags, {
    NodeGroupName = "eks-${var.cluster_name}-node-group"
  })

  depends_on = [aws_eks_cluster.eks_cluster]
}

##autoscaling  cross check shoul dgo to self or eks managed node 

# resource "aws_autoscaling_group" "eks_node_group_asg" {
#   desired_capacity     = var.node_group_desired_size
#   max_size             = var.node_group_max_size
#   min_size             = var.node_group_min_size
#   vpc_zone_identifier  = var.subnet_ids
#   launch_configuration = aws_launch_configuration.eks_launch_config.id

#   tags = [
#     {
#       key                 = "Name"
#       value               = "eks-${var.cluster_name}-node-group"
#       propagate_at_launch = true
#     }
#   ]
# }

# resource "aws_launch_configuration" "eks_launch_config" {
#   name          = "eks-${var.cluster_name}-launch-config"
#   image_id      = var.node_group_ami_id
#   instance_type = var.node_group_instance_types[0]

#   security_groups = [aws_security_group.eks_node_group_sg.id]

#   lifecycle {
#     create_before_destroy = true
#   }
# }




#######################
# IAM Role for EKS Node Group
#######################

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  tags = merge(var.default_tags, {
    Name = "eks-${var.cluster_name}-node-group-role"
  })
}

resource "aws_iam_policy" "eks_node_group_policy" {
  name        = "eks-${var.cluster_name}-node-group-policy"
  description = "Policy for EKS Node Group ${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion",
          "eks:DeleteNodegroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:ModifyInstanceAttribute",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_role_policy_attachment" {
  policy_arn = aws_iam_policy.eks_node_group_policy.arn
  role       = aws_iam_role.eks_node_group_role.name
}

#######################
# Security Group for EKS Node Group
#######################

resource "aws_security_group" "eks_node_group" {
  name        = "eks-${var.cluster_name}-node-group-sg"
  description = "Security group for EKS Node Group"
  vpc_id      = var.vpc_id

  tags = merge(var.default_tags, {
    Name = "eks-${var.cluster_name}-node-group-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "eks_node_group_ingress" {
  security_group_id = aws_security_group.eks_node_group.id
  protocol          = var.security_group_protocol
  from_port         = var.security_group_from_port
  to_port           = var.security_group_to_port
  type              = var.security_group_type
  description       = var.security_group_description
  cidr_blocks       = var.security_group_cidr_blocks
}

#######################
# EC2 Tags for Node Group Resources
#######################

resource "aws_ec2_tag" "eks_node_group_security_group_tag" {
  resource_id = aws_security_group.eks_node_group.id
  key         = "Name"
  value       = "eks-${var.cluster_name}-node-group-sg"
}

resource "aws_ec2_tag" "eks_node_group_subnet_tag" {
  for_each = toset(var.subnet_ids)

  resource_id = each.value
  key         = "Name"
  value       = "eks-${var.cluster_name}-node-group-subnet-${each.key}"
}
