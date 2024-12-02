resource "aws_eks_cluster" "this" {
  name                          = "${var.cluster_name}-${var.region}-${var.environment}"
  role_arn                      = try(aws_iam_role.this[0].arn, var.iam_role_arn)
  version                       = var.version
  enabled_cluster_log_types     = var.enabled_cluster_log_types
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    security_group_ids      = compact(distinct(concat(var.cluster_additional_security_group_ids, [aws_security_group.this.id])))
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    for_each = !length(var.outpost_config) > 0 ? [1] : []

    content {
      ip_family         = var.cluster_ip_family
      service_ipv4_cidr = var.cluster_service_ipv4_cidr
    }
  }

  dynamic "outpost_config" {
    for_each = length(var.outpost_config) > 0 ? [var.outpost_config] : []

    content {
      control_plane_instance_type = outpost_config.value.control_plane_instance_type
      outpost_arns                = outpost_config.value.outpost_arns
    }
  }

  dynamic "encryption_config" {
    for_each = length(var.cluster_encryption_config) > 0 && !length(var.outpost_config) > 0 ? [var.cluster_encryption_config] : []

    content {
      provider {
        key_arn = var.create_kms_key ? module.kms.key_arn : encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  dynamic "upgrade_policy" {
    for_each = length(var.cluster_upgrade_policy) > 0 ? [var.cluster_upgrade_policy] : []

    content {
      support_type = try(upgrade_policy.value.support_type, null)
    }
  }

  dynamic "zonal_shift_config" {
    for_each = length(var.cluster_zonal_shift_config) > 0 ? [var.cluster_zonal_shift_config] : []

    content {
      enabled = try(zonal_shift_config.value.enabled, null)
    }
  }

  tags = merge(
    { terraform-aws-modules = "eks" },
    var.tags,
    var.cluster_tags,
    { "ClusterName" = "${var.cluster_name}-${var.region}-${var.environment}" }
  )

  timeouts {
    create = try(var.cluster_timeouts.create, null)
    update = try(var.cluster_timeouts.update, null)
    delete = try(var.cluster_timeouts.delete, null)
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





#################### tvars 
cluster_name                  = "my-cluster"
version                       = "1.23"
enabled_cluster_log_types     = ["api", "audit"]
bootstrap_self_managed_addons = ["vpc-cni"]

region                                 = "us-west-2"
environment                            = "dev"
iam_role_arn                           = "arn:aws:iam::123456789012:role/my-eks-role"
subnet_ids                             = ["subnet-abc123", "subnet-def456"]
cluster_additional_security_group_ids  = ["sg-12345678"]
cluster_endpoint_private_access        = true
cluster_endpoint_public_access         = true
cluster_endpoint_public_access_cidrs   = ["0.0.0.0/0"]
cluster_ip_family                      = "ipv4"
cluster_service_ipv4_cidr              = "10.100.0.0/16"
outpost_config                         = []
cluster_encryption_config              = []
create_kms_key                         = false
cluster_upgrade_policy                 = []
cluster_zonal_shift_config             = []
cloudwatch_log_group_retention_in_days = 30
cloudwatch_log_group_kms_key_id        = ""
cloudwatch_log_group_class             = "Standard"
tags = {
  "Project" = "MyEKSProject"
}
cluster_tags = {
  "Environment" = "Dev"
}
cloudwatch_log_group_tags = {
  "Environment" = "Dev"
}
cluster_timeouts = {
  create = "30m"
  update = "30m"
  delete = "30m"
}
create_cluster_primary_security_group_tags = true
