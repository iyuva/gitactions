data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}


################################################################################
# Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  for_each = var.clusters

  name                          = each.value.cluster_name
  role_arn                      = local.cluster_role
  version                       = each.value.cluster_version
  enabled_cluster_log_types     = each.value.cluster_enabled_log_types
  bootstrap_self_managed_addons = each.value.bootstrap_self_managed_addons

  access_config {
    authentication_mode                     = each.value.authentication_mode
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    vpc_id                  = each.value.vpc_config.vpc_id
    subnet_ids              = each.value.subnet_ids
    endpoint_private_access = each.value.cluster_endpoint_private_access
    endpoint_public_access  = each.value.cluster_endpoint_public_access
    public_access_cidrs     = each.value.cluster_endpoint_public_access_cidrs
  }

  # Optional kubernetes network configuration for Outposts
  dynamic "kubernetes_network_config" {
    for_each = each.value.create_outposts_local_cluster ? [1] : []
    content {
      ip_family         = each.value.cluster_ip_family
      service_ipv4_cidr = each.value.cluster_service_ipv4_cidr
      service_ipv6_cidr = each.value.cluster_service_ipv6_cidr
    }
  }

  # Optional outpost config
  dynamic "outpost_config" {
    for_each = each.value.create_outposts_local_cluster ? [each.value.outpost_config] : []
    content {
      control_plane_instance_type = outpost_config.value.control_plane_instance_type
      outpost_arns                = outpost_config.value.outpost_arns
    }
  }

  # Optional encryption config
  dynamic "encryption_config" {
    for_each = length(each.value.cluster_encryption_config) > 0 ? [each.value.cluster_encryption_config] : []
    content {
      provider {
        key_arn = each.value.create_kms_key ? module.kms.key_arn : encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  # Optional upgrade policy
  dynamic "upgrade_policy" {
    for_each = length(each.value.cluster_upgrade_policy) > 0 ? [each.value.cluster_upgrade_policy] : []
    content {
      support_type = try(upgrade_policy.value.support_type, null)
    }
  }

  # Optional zonal shift config
  dynamic "zonal_shift_config" {
    for_each = length(each.value.cluster_zonal_shift_config) > 0 ? [each.value.cluster_zonal_shift_config] : []
    content {
      enabled = try(zonal_shift_config.value.enabled, null)
    }
  }

  tags = merge(
    { terraform-aws-modules = "eks" },
    each.value.tags,
    each.value.cluster_tags
  )

  timeouts {
    create = try(each.value.cluster_timeouts.create, null)
    update = try(each.value.cluster_timeouts.update, null)
    delete = try(each.value.cluster_timeouts.delete, null)
  }

  depends_on = [
    aws_iam_role_policy_attachment.this,
    aws_security_group_rule.cluster,
    aws_security_group_rule.node,
    aws_cloudwatch_log_group.this,
    aws_iam_policy.cni_ipv6_policy,
  ]

  lifecycle {
    ignore_changes = [
      access_config[0].bootstrap_cluster_creator_admin_permissions
    ]
  }
}



################


#### aws ec2 tags ### 


resource "aws_ec2_tag" "cluster_primary_security_group" {
  # Tags the security group for the EKS cluster primary security group
  # It avoids the "Name" tag and only applies tags if var.create_cluster_primary_security_group_tags is true.
  for_each = {
    for k, v in merge(var.tags, var.cluster_tags) : 
    k => v if local.create && k != "Name" && var.create_cluster_primary_security_group_tags
  }

  resource_id = aws_eks_cluster.this[each.key].vpc_config[0].cluster_security_group_id
  key         = each.key
  value       = each.value
}



### aws cloudwatch  ####

# resource "aws_cloudwatch_log_group" "this" {
#   for_each = {
#     for cluster_key, cluster_value in var.clusters : 
#     cluster_key => cluster_value if local.create && var.create_cloudwatch_log_group
#   }

#   name              = "/aws/eks/${each.value.cluster_name}/cluster"
#   retention_in_days = var.cloudwatch_log_group_retention_in_days
#   kms_key_id        = var.cloudwatch_log_group_kms_key_id
#   log_group_class   = var.cloudwatch_log_group_class

#   tags = merge(
#     var.tags,
#     var.cloudwatch_log_group_tags,
#     { Name = "/aws/eks/${each.value.cluster_name}/cluster" }
#   )
# }


################################################################################
# Access Entry
################################################################################


resource "aws_eks_access_entry" "this" {
  for_each = { 
    for entry_key, entry_val in merge(
      { 
        cluster_creator = {
          principal_arn = data.aws_iam_session_context.current.issuer_arn
          type          = "STANDARD"
          policy_associations = {
            admin = {
              policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
              access_scope = {
                type = "cluster"
              }
            }
          }
        }
      }, 
      var.access_entries
    ) : entry_key => entry_val if var.enable_cluster_creator_admin_permissions && var.create 
  }

  cluster_name      = aws_eks_cluster.this[0].id
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  principal_arn     = each.value.principal_arn
  type              = try(each.value.type, "STANDARD")
  user_name         = try(each.value.user_name, null)

  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_eks_access_policy_association" "this" {
  for_each = { 
    for entry_key, entry_val in flatten(
      [
        for entry_key, entry_val in merge(
          { 
            cluster_creator = {
              principal_arn = data.aws_iam_session_context.current.issuer_arn
              type          = "STANDARD"
              policy_associations = {
                admin = {
                  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                  access_scope = {
                    type = "cluster"
                  }
                }
              }
            }
          },
          var.access_entries
        ) : [
          for pol_key, pol_val in lookup(entry_val, "policy_associations", {}) : merge(
            {
              principal_arn = entry_val.principal_arn
              entry_key     = entry_key
              pol_key       = pol_key
            },
            {
              association_policy_arn              = pol_val.policy_arn
              association_access_scope_type       = pol_val.access_scope.type
              association_access_scope_namespaces = lookup(pol_val.access_scope, "namespaces", [])
            }
          )
        ]
      ]
    ) : "${entry_val.entry_key}_${entry_val.pol_key}" => entry_val if var.create 
  }

  access_scope {
    namespaces = try(each.value.association_access_scope_namespaces, [])
    type       = each.value.association_access_scope_type
  }

  cluster_name = aws_eks_cluster.this[0].id

  policy_arn    = each.value.association_policy_arn
  principal_arn = each.value.principal_arn

  depends_on = [
    aws_eks_access_entry.this,
  ]
}

################################################################################
# KMS Key
################################################################################


################################################################################
# Cluster Security Group
################################################################################ 


resource "aws_security_group" "cluster" {
  count = var.create && var.create_cluster_security_group ? 1 : 0

  name        = var.cluster_security_group_use_name_prefix ? null : coalesce(var.cluster_security_group_name, "${var.cluster_name}-cluster")
  name_prefix = var.cluster_security_group_use_name_prefix ? "${coalesce(var.cluster_security_group_name, "${var.cluster_name}-cluster")}${var.prefix_separator}" : null
  description = var.cluster_security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = coalesce(var.cluster_security_group_name, "${var.cluster_name}-cluster") },
    var.cluster_security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster" {
  for_each = { for k, v in merge(
    { 
      ingress_nodes_443 = {
        description                = "Node groups to cluster API"
        protocol                   = "tcp"
        from_port                  = 443
        to_port                    = 443
        type                       = "ingress"
        source_node_security_group = true
      }
    },
    var.cluster_security_group_additional_rules
  ) : k => v if var.create && var.create_cluster_security_group }

  # Required
  security_group_id = aws_security_group.cluster[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description              = lookup(each.value, "description", null)
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  self                     = lookup(each.value, "self", null)
  source_security_group_id = try(each.value.source_node_security_group, false) ? var.node_security_group_id : lookup(each.value, "source_security_group_id", null)
}


####################################################################################
# IRSA
# Note - this is different from EKS identity provider
################################################################################


resource "data" "tls_certificate" "this" {
  count = var.create && var.enable_irsa && !var.create_outposts_local_cluster && var.include_oidc_root_ca_thumbprint ? 1 : 0

  url = aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count = var.create && var.enable_irsa && !var.create_outposts_local_cluster ? 1 : 0

  client_id_list  = distinct(compact(concat(["sts.amazonaws.com"], var.openid_connect_audiences)))
  thumbprint_list = concat(
    var.include_oidc_root_ca_thumbprint ? [data.tls_certificate.this[0].certificates[0].sha1_fingerprint] : [],
    var.custom_oidc_thumbprints
  )
  url             = aws_eks_cluster.this[0].identity[0].oidc[0].issuer

  tags = merge(
    { Name = "${var.cluster_name}-eks-irsa" },
    var.tags
  )
}



################################################################################
# IAM Role
################################################################################


data "aws_iam_policy_document" "assume_role_policy" {
  for_each = var.clusters

  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    dynamic "principals" {
      for_each = each.value.create_outposts_local_cluster ? [1] : []

      content {
        type = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = var.clusters

  name        = var.iam_role_use_name_prefix ? null : "${each.value.cluster_name}-cluster"
  name_prefix = var.iam_role_use_name_prefix ? "${each.value.cluster_name}-cluster" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[each.key].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in {
    AmazonEKSClusterPolicy         = each.value.create_outposts_local_cluster ? "${var.iam_role_policy_prefix}/AmazonEKSLocalOutpostClusterPolicy" : "${var.iam_role_policy_prefix}/AmazonEKSClusterPolicy",
    AmazonEKSVPCResourceController = "${var.iam_role_policy_prefix}/AmazonEKSVPCResourceController",
  } : k => v if var.create_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.this[each.key].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v if var.create_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.this[each.key].name
}

resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  for_each = var.clusters

  count = var.create_iam_role && var.attach_cluster_encryption_policy && var.enable_cluster_encryption_config ? 1 : 0

  policy_arn = aws_iam_policy.cluster_encryption[each.key].arn
  role       = aws_iam_role.this[each.key].name
}

resource "aws_iam_policy" "cluster_encryption" {
  for_each = var.clusters

  count = var.create_iam_role && var.attach_cluster_encryption_policy && var.enable_cluster_encryption_config ? 1 : 0

  name        = var.cluster_encryption_policy_use_name_prefix ? null : "${each.value.cluster_name}-ClusterEncryption"
  name_prefix = var.cluster_encryption_policy_use_name_prefix ? "${each.value.cluster_name}-ClusterEncryption" : null
  description = var.cluster_encryption_policy_description
  path        = var.cluster_encryption_policy_path

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:DescribeKey",
        ]
        Effect   = "Allow"
        Resource = var.create_kms_key ? module.kms.key_arn : each.value.cluster_encryption_config.provider_key_arn
      },
    ]
  })

  tags = merge(var.tags, var.cluster_encryption_policy_tags)
}




################################################################################
# EKS Addons
################################################################################

data "aws_eks_addon_version" "this" {
  for_each = { for k, v in var.cluster_addons : k => v if var.create && !var.create_outposts_local_cluster }

  addon_name         = try(each.value.name, each.key)
  kubernetes_version = coalesce(var.cluster_version, aws_eks_cluster.this[0].version)
  most_recent        = try(each.value.most_recent, null)
}

resource "aws_eks_addon" "this" {
  for_each = { for k, v in var.cluster_addons : k => v if !try(v.before_compute, false) && var.create && !var.create_outposts_local_cluster }

  cluster_name = aws_eks_cluster.this[0].id
  addon_name   = try(each.value.name, each.key)

  addon_version        = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values = try(each.value.configuration_values, null)

  dynamic "pod_identity_association" {
    for_each = try(each.value.pod_identity_association, [])

    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  preserve = try(each.value.preserve, true)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, var.bootstrap_self_managed_addons ? "OVERWRITE" : "NONE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  timeouts {
    create = try(each.value.timeouts.create, var.cluster_addons_timeouts.create, null)
    update = try(each.value.timeouts.update, var.cluster_addons_timeouts.update, null)
    delete = try(each.value.timeouts.delete, var.cluster_addons_timeouts.delete, null)
  }

  depends_on = [
    module.fargate_profile,
    module.eks_managed_node_group,
    module.self_managed_node_group,
  ]

  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_eks_addon" "before_compute" {
  for_each = { for k, v in var.cluster_addons : k => v if try(v.before_compute, false) && var.create && !var.create_outposts_local_cluster }

  cluster_name = aws_eks_cluster.this[0].id
  addon_name   = try(each.value.name, each.key)

  addon_version        = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values = try(each.value.configuration_values, null)

  dynamic "pod_identity_association" {
    for_each = try(each.value.pod_identity_association, [])

    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  preserve = try(each.value.preserve, true)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, var.bootstrap_self_managed_addons ? "OVERWRITE" : "NONE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  timeouts {
    create = try(each.value.timeouts.create, var.cluster_addons_timeouts.create, null)
    update = try(each.value.timeouts.update, var.cluster_addons_timeouts.update, null)
    delete = try(each.value.timeouts.delete, var.cluster_addons_timeouts.delete, null)
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}




################################################################################
# EKS Identity Provider
# Note - this is different from IRSA
################################################################################



# resource "aws_eks_identity_provider_config" "this" {
#   for_each = { 
#     for k, v in var.cluster_identity_providers : k => v if var.create && !var.create_outposts_local_cluster 
#   }

#   cluster_name = aws_eks_cluster.this[0].id

#   oidc {
#     client_id                     = each.value.client_id
#     groups_claim                  = lookup(each.value, "groups_claim", null)
#     groups_prefix                 = lookup(each.value, "groups_prefix", null)
#     identity_provider_config_name = try(each.value.identity_provider_config_name, each.key)

#     # Determine issuer_url for versions <= 1.29
#     issuer_url = try(
#       each.value.issuer_url,
#       contains(
#         ["1.21", "1.22", "1.23", "1.24", "1.25", "1.26", "1.27", "1.28", "1.29"], 
#         coalesce(var.cluster_version, "1.30")
#       ) ? try(aws_eks_cluster.this[0].identity[0].oidc[0].issuer, null) : null
#     )

#     required_claims = lookup(each.value, "required_claims", null)
#     username_claim  = lookup(each.value, "username_claim", null)
#     username_prefix = lookup(each.value, "username_prefix", null)
#   }

#   tags = merge(var.tags, try(each.value.tags, {}))
# }



###  EKS Identity Provider
### IRSA
### Cluster Security Group
### KMS key ----after completion of KMS module add KMS stuff 
### 






