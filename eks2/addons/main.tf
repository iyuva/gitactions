# modules/eks/main.tf
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Any other EKS configuration you need
}

# Define EKS add-ons
resource "aws_eks_addon" "addon" {
  for_each = var.addons

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.key
  addon_version = each.value.version
  service_account_role_arn = each.value.service_account_role_arn

  # Optional: Define configuration for specific add-ons
  config {
    key = each.value.config.key
    value = each.value.config.value
  }
}





###########################
locals {
  resolve_conflicts_on_create_default = coalesce(var.bootstrap_self_managed_addons, true) ? "OVERWRITE" : "NONE"
}

# Define a helper function to get common addon configuration
locals {
  addon_configuration = { for k, v in var.cluster_addons : k => {
    addon_name               = try(v.name, k)
    addon_version            = coalesce(try(v.addon_version, null), data.aws_eks_addon_version.this[k].version)
    configuration_values     = try(v.configuration_values, null)
    pod_identity_association = try(v.pod_identity_association, [])
    preserve                 = try(v.preserve, true)
    resolve_conflicts_on_create = try(v.resolve_conflicts_on_create, local.resolve_conflicts_on_create_default)
    resolve_conflicts_on_update = try(v.resolve_conflicts_on_update, "OVERWRITE")
    service_account_role_arn  = try(v.service_account_role_arn, null)
    timeouts_create           = try(v.timeouts.create, var.cluster_addons_timeouts.create, null)
    timeouts_update           = try(v.timeouts.update, var.cluster_addons_timeouts.update, null)
    timeouts_delete           = try(v.timeouts.delete, var.cluster_addons_timeouts.delete, null)
    tags                      = merge(var.tags, try(v.tags, {}))
  }}
}

# Data source to get the EKS addon version
data "aws_eks_addon_version" "this" {
  for_each = { for k, v in local.addon_configuration : k => v if var.create && !var.create_outposts_local_cluster }

  addon_name         = each.value.addon_name
  kubernetes_version = coalesce(var.cluster_version, aws_eks_cluster.this[0].version)
  most_recent        = try(each.value.most_recent, null)
}

# Define a resource for each EKS addon, both before and after compute
resource "aws_eks_addon" "this" {
  for_each = { for k, v in local.addon_configuration : k => v if !try(v.before_compute, false) && var.create && !var.create_outposts_local_cluster }

  cluster_name            = aws_eks_cluster.this[0].id
  addon_name              = each.value.addon_name
  addon_version           = each.value.addon_version
  configuration_values    = each.value.configuration_values

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_association

    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  preserve                 = each.value.preserve
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  service_account_role_arn    = each.value.service_account_role_arn

  timeouts {
    create = each.value.timeouts_create
    update = each.value.timeouts_update
    delete = each.value.timeouts_delete
  }

  tags = each.value.tags

  depends_on = [
    module.fargate_profile,
    module.eks_managed_node_group,
    module.self_managed_node_group,
  ]
}

resource "aws_eks_addon" "before_compute" {
  for_each = { for k, v in local.addon_configuration : k => v if try(v.before_compute, false) && var.create && !var.create_outposts_local_cluster }

  cluster_name            = aws_eks_cluster.this[0].id
  addon_name              = each.value.addon_name
  addon_version           = each.value.addon_version
  configuration_values    = each.value.configuration_values

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_association

    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  preserve                 = each.value.preserve
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  service_account_role_arn    = each.value.service_account_role_arn

  timeouts {
    create = each.value.timeouts_create
    update = each.value.timeouts_update
    delete = each.value.timeouts_delete
  }

  tags = each.value.tags
}
