provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}


####################################
## IAM 
###################################

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })

  tags = {
    Name = "eks-cluster-role"
  }
}

resource "aws_iam_policy" "eks_policy" {
  name        = "eks-cluster-policy"
  description = "EKS Cluster policy for managing EKS control plane"

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
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_attachment" {
  policy_arn = aws_iam_policy.eks_policy.arn
  role       = aws_iam_role.eks_role.name
}



#####################################################
## EKS Cluster 
#####################################################




resource "aws_eks_cluster" "eks_cluster" {
  for_each = var.cluster_names

  name                          = each.key
  role_arn                      = aws_iam_role.eks_role.arn
  version                       = each.value.version
  enabled_cluster_log_types     = each.value.enabled_log_types
  bootstrap_self_managed_addons = each.value.bootstrap_addons

  access_config {
    authentication_mode                         = each.value.authentication_mode
    bootstrap_cluster_creator_admin_permissions = each.value.cluster_creator_permissions
  }

  vpc_config {
    security_group_ids      = [aws_security_group.eks_control_plane.id] #each.value.security_group_ids
    subnet_ids              = each.value.subnet_ids
    endpoint_private_access = each.value.endpoint_private_access
    endpoint_public_access  = each.value.endpoint_public_access
    public_access_cidrs     = each.value.public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    for_each = var.cluster_ip_family != null ? [1] : []
    content {
      ip_family         = var.cluster_ip_family
      service_ipv4_cidr = var.cluster_service_ipv4_cidr
      #service_ipv6_cidr = var.cluster_service_ipv6_cidr
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



  dynamic "upgrade_policy" {
    for_each = var.cluster_upgrade_policy != null ? [var.cluster_upgrade_policy] : []
    content {
      support_type = try(upgrade_policy.value.support_type, null)
    }
  }

  dynamic "zonal_shift_config" {
    for_each = var.cluster_zonal_shift_config != null ? [var.cluster_zonal_shift_config] : []
    content {
      enabled = try(zonal_shift_config.value.enabled, null)
    }
  }

  tags = merge(
    var.default_tags,
    {
      "ClusterName" = each.key
    }
  )

  timeouts {
    create = try(each.value.cluster_timeouts.create, "30m")
    update = try(each.value.cluster_timeouts.update, "20m")
    delete = try(each.value.cluster_timeouts.delete, "30m")
  }

  depends_on = [
    aws_iam_role.eks_role
  ]

  lifecycle {
    ignore_changes = [
      kubernetes_network_config,
      outpost_config,
      encryption_config,
      upgrade_policy,
      zonal_shift_config
    ]
  }
}


####################################
## EKS Access Entry
###################################

resource "aws_eks_access_entry" "eks_access_entry" {
  for_each = var.cluster_access_entries

  cluster_name      = aws_eks_cluster.eks_cluster[each.key].name
  kubernetes_groups = each.value.kubernetes_groups
  principal_arn     = each.value.principal_arn
  type              = each.value.type
  user_name         = each.value.user_name

  tags = merge(var.default_tags, try(each.value.tags, {}))
}

####################################
## EKS Access Policy Association
###################################

resource "aws_eks_access_policy_association" "eks_access_policy_association" {
  for_each = var.cluster_access_policy_associations

  access_scope {
    namespaces = each.value.namespaces
    type       = each.value.type
  }

  cluster_name  = aws_eks_cluster.eks_cluster[each.key].name
  policy_arn    = each.value.policy_arn
  principal_arn = each.value.principal_arn

  depends_on = [
    aws_eks_access_entry.eks_access_entry,
  ]
}




####################################
##Security Group for EKS Cluster
#######################################


resource "aws_security_group" "eks_control_plane" {
  name        = "eks-control-plane"
  description = "Security group for EKS Control Plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.default_tags,
    {
      "Name" = "eks-control-plane"
    },
    var.cluster_security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

###### Security Group Rules for EKS Cluster

# resource "aws_security_group_rule" "eks_control_plane_ingress" {
#   for_each = var.security_group_rules

#   # Required
#   security_group_id = aws_security_group.eks_control_plane.id
#   protocol          = each.value.protocol
#   from_port         = each.value.from_port
#   to_port           = each.value.to_port
#   type              = each.value.type

#   # Optional
#   description              = lookup(each.value, "description", null)
#   cidr_blocks              = lookup(each.value, "cidr_blocks", null)
#   ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
#   prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
#   self                     = lookup(each.value, "self", null)
#   source_security_group_id = lookup(each.value, "source_security_group_id", null)
# }

resource "aws_security_group_rule" "eks_control_plane_ingress" {
  for_each = var.security_group_rules

  # Required
  security_group_id = aws_security_group.eks_control_plane.id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description = lookup(each.value, "description", null)

  # Ensure at least one of these is specified
  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? lookup(each.value, "cidr_blocks", null) : []
  #ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null) != null ? lookup(each.value, "ipv6_cidr_blocks", null) : []
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null) != null ? lookup(each.value, "prefix_list_ids", null) : []
  self                     = lookup(each.value, "self", null) != null ? lookup(each.value, "self", null) : null
  source_security_group_id = lookup(each.value, "source_security_group_id", null) != null ? lookup(each.value, "source_security_group_id", null) : null
}




####################################
## Tagging EC2 Instances (Including Security Groups, Subnets , check ---yuva
###################################


# Tagging EC2 security group
resource "aws_ec2_tag" "eks_security_group_tag" {
  resource_id = aws_security_group.eks_control_plane.id
  key         = "Name"
  value       = "eks-control-plane-sg"
}

# Tagging EC2 Subnets
resource "aws_ec2_tag" "eks_subnet_tag" {
  for_each = toset(var.subnet_ids)

  resource_id = each.value
  key         = "Name"
  value       = "eks-subnet"
}




####################################
## IAM Roles and Policies for Addons
####################################

resource "aws_iam_role" "eks_addon_role" {
  for_each = var.eks_addons

  name = "eks-${each.key}-addon-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })

  tags = {
    Name = "eks-${each.key}-addon-role"
  }
}

resource "aws_iam_policy" "eks_addon_policy" {
  for_each = var.eks_addons

  name        = "eks-${each.key}-addon-policy"
  description = "EKS Addon policy for managing pod identity association"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = aws_iam_role.eks_addon_role[each.key].arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_addon_policy_attachment" {
  for_each = var.eks_addons

  policy_arn = aws_iam_policy.eks_addon_policy[each.key].arn
  role       = aws_iam_role.eks_addon_role[each.key].name
}

##########################################
## EKS Addons Configuration
##########################################

# resource "aws_eks_addon" "eks_addon" {
#   for_each = var.eks_addons

#   cluster_name             = aws_eks_cluster.eks_cluster[each.key].name
#   addon_name               = each.value.addon_name
#   addon_version            = each.value.addon_version
#   configuration_values     = jsonencode(each.value.configuration_values)
#   service_account_role_arn = each.value.service_account_role_arn

#   preserve                    = each.value.preserve
#   resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
#   resolve_conflicts_on_update = each.value.resolve_conflicts_on_update

#   timeouts {
#     create = "30m"
#     update = "20m"
#     delete = "30m"
#   }

#   tags = merge(var.default_tags, try(each.value.tags, {}))
# }



# resource "aws_iam_role" "eks_addon_role" {
#   for_each = var.eks_addons

#   name = "eks-${each.key}-addon-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Effect = "Allow"
#         Sid    = ""
#       },
#     ]
#   })

#   tags = {
#     Name = "eks-${each.key}-addon-role"
#   }
# }

# resource "aws_iam_policy" "eks_addon_policy" {
#   for_each = var.eks_addons

#   name        = "eks-${each.key}-addon-policy"
#   description = "EKS Addon policy for managing pod identity association"

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

# resource "aws_iam_role_policy_attachment" "eks_addon_policy_attachment" {
#   for_each = var.eks_addons

#   policy_arn = aws_iam_policy.eks_addon_policy[each.key].arn
#   role       = aws_iam_role.eks_addon_role[each.key].name
# }


##



# resource "aws_eks_addon" "eks_addon" {
#   for_each = var.eks_addons

#   # Ensure the cluster_name matches the key in aws_eks_cluster
#   cluster_name  = aws_eks_cluster.eks_cluster[each.key].name
#   addon_name    = each.value.addon_name
#   addon_version = each.value.addon_version
#   #service_account_role_arn = each.value.service_account_role_arn

#   # Convert configuration_values map to JSON string
#   configuration_values = jsonencode(each.value.configuration_values)

#   service_account_role_arn = each.value.service_account_role_arn

#   tags = merge(var.default_tags, try(each.value.tags, {}))
# }

# resource "aws_eks_addon" "eks_addon" {
#   for_each = var.eks_addons

#   cluster_name         = aws_eks_cluster.eks_cluster[each.key].name
#   addon_name           = each.value.addon_name
#   addon_version        = each.value.addon_version
#   configuration_values = each.value.configuration_values

#   dynamic "pod_identity_association" {
#     for_each = each.value.pod_identity_association != null ? [1] : []

#     content {
#       role_arn        = aws_iam_role.eks_addon_role[each.key].arn
#       service_account = each.value.pod_identity_association.service_account
#     }
#   }

#   preserve                    = try(each.value.preserve, true)
#   resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
#   resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
#   service_account_role_arn    = each.value.service_account_role_arn

#   timeouts {
#     create = try(each.value.timeouts.create, "30m")
#     update = try(each.value.timeouts.update, "20m")
#     delete = try(each.value.timeouts.delete, "30m")
#   }

#   tags = merge(var.default_tags, try(each.value.tags, {}))
# }





############################################################
###### aws_eks_identity_provider_config
############################################################



# resource "aws_eks_identity_provider_config" "eks_identity_provider" {
#   for_each = var.eks_identity_provider_configs

#   cluster_name = aws_eks_cluster.eks_cluster[each.key].name

#   oidc {
#     client_id                     = each.value.client_id
#     groups_claim                  = lookup(each.value, "groups_claim", null)                # Optional field, default is null
#     groups_prefix                 = lookup(each.value, "groups_prefix", null)               # Optional field, default is null
#     identity_provider_config_name = try(each.value.identity_provider_config_name, each.key) # Use key as fallback
#     issuer_url                    = try(each.value.issuer_url, "https://example.com")       # Fallback directly here    
#     required_claims               = lookup(each.value, "required_claims", null)             # Optional, default is null
#     username_claim                = lookup(each.value, "username_claim", null)              # Optional, default is null
#     username_prefix               = lookup(each.value, "username_prefix", null)             # Optional, default is null
#   }

#   tags = merge(var.default_tags, try(each.value.tags, {}))
# }

# resource "aws_eks_identity_provider_config" "eks_identity_provider" {
#   for_each = var.eks_identity_provider_configs

#   # Ensure the cluster_name matches the key in aws_eks_cluster
#   cluster_name = aws_eks_cluster.eks_cluster[each.key].name

#   oidc {
#     client_id                     = each.value.client_id
#     groups_claim                  = lookup(each.value, "groups_claim", null)
#     groups_prefix                 = lookup(each.value, "groups_prefix", null)
#     identity_provider_config_name = try(each.value.identity_provider_config_name, each.key)
#     issuer_url                    = try(each.value.issuer_url, "https://example.com")
#     required_claims               = each.value.required_claims != null ? each.value.required_claims : {}

#     username_claim  = lookup(each.value, "username_claim", null)
#     username_prefix = lookup(each.value, "username_prefix", null)
#   }

#   tags = merge(var.default_tags, try(each.value.tags, {}))
# }








