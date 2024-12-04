provider "aws" {
  region     = "us-east-1"                                # Adjust to your preferred AWS region
  access_key = "AKIA2EKS7QO234XESMWG"                     # Your AWS access key
  secret_key = "mOI8+jt3A59af4GviJ/753qy7RsvZW16spqeiw5C" # Your AWS secret key

}

#######################
# IAM Resources
#######################

resource "aws_iam_role" "eks_role" {
  name = var.eks_role_name

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
    Name = var.eks_role_name
  })
}

resource "aws_iam_policy" "eks_policy" {
  name        = var.eks_policy_name
  description = var.eks_policy_description

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
    security_group_ids      = [aws_security_group.eks_control_plane.id]
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

  upgrade_policy {
    support_type = var.cluster_upgrade_policy
  }

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

resource "aws_security_group" "eks_control_plane" {
  name        = var.eks_security_group_name
  description = "Security group for EKS Control Plane"
  vpc_id      = var.vpc_id

  tags = merge(var.default_tags, {
    Name = var.eks_security_group_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "eks_control_plane_ingress" {
  security_group_id = aws_security_group.eks_control_plane.id
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
  resource_id = aws_security_group.eks_control_plane.id
  key         = "Name"
  value       = var.eks_security_group_name
}

resource "aws_ec2_tag" "eks_subnet_tag" {
  for_each = toset(var.subnet_ids)

  resource_id = each.value
  key         = "Name"
  value       = var.subnet_name
}

# #######################
# # IAM Roles and Policies for Addons
# #######################


# # IAM Roles and Policies for EKS Addons
# resource "aws_iam_role" "eks_addon_role" {
#   for_each = var.addon_names

#   name = "eks-${each.value}-role"

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
#     Name = "eks-${each.value}-role"
#   }
# }

# resource "aws_iam_policy" "eks_addon_policy" {
#   for_each = var.addon_names

#   name        = "eks-${each.value}-policy"
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

# #######################
# # EKS Addon Installation
# #######################

# resource "aws_eks_addon" "eks_addon" {
#   for_each = var.addon_names

#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   addon_name    = each.value
#   addon_version = var.addon_versions[each.value] # Make sure this is defined in your variables
# }

############################################################
###### aws_eks_identity_provider_config
############################################################



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

####################################
## EKS Access Entry AND Policy Association
###################################

resource "aws_eks_access_entry" "eks_access_entry" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  kubernetes_groups = var.kubernetes_groups
  principal_arn     = var.principal_arn
  type              = var.access_entry_type
  user_name         = var.user_name

  tags = merge(var.default_tags, var.access_entry_tags)
}

resource "aws_eks_access_policy_association" "eks_access_policy_association" {
  access_scope {
    namespaces = var.access_policy_namespaces
    type       = var.access_policy_type
  }

  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = var.access_policy_arn
  principal_arn = var.access_policy_principal_arn
}




#######################
