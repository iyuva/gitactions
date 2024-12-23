# data "aws_partition" "current" {}

# data "aws_caller_identity" "current" {}

# data "aws_iam_session_context" "current" {
#   arn = try(data.aws_caller_identity.current.arn, "")
# }




# ##########################
# # EKS Cluster Configuration
# ##########################
# resource "aws_eks_cluster" "eks_cluster" { # Changed name to eks_cluster
#   for_each = var.eks_clusters

#   name                          = each.value.cluster_name
#   role_arn                      = aws_iam_role.eks_cluster_role[each.key].arn
#   version                       = each.value.cluster_version
#   enabled_cluster_log_types     = each.value.cluster_enabled_log_types
#   bootstrap_self_managed_addons = each.value.bootstrap_self_managed_addons

#   access_config {
#     authentication_mode = each.value.authentication_mode

#     bootstrap_cluster_creator_admin_permissions = try(each.value.bootstrap_cluster_creator_admin_permissions, false)
#   }

#   vpc_config {
#     security_group_ids      = aws_security_group.eks_sg_dynamic
#     endpoint_private_access = each.value.cluster_endpoint_private_access
#     endpoint_public_access  = each.value.cluster_endpoint_public_access
#     public_access_cidrs     = each.value.cluster_endpoint_public_access_cidrs
#     subnet_ids              = each.value.subnet_ids
#   }

#   kubernetes_network_config {
#     ip_family         = each.value.cluster_ip_family
#     service_ipv4_cidr = each.value.cluster_service_ipv4_cidr
#     service_ipv6_cidr = each.value.cluster_service_ipv6_cidr
#   }

#   # KMS Encryption (Optional)
#   encryption_config {
#     provider {
#       key_arn = each.value.kms_key_arn
#     }
#     resources = ["secrets"]
#   }

#   # Upgrade Policy
#   upgrade_policy {
#     support_type = each.value.upgrade_policy_support_type # Can be "STANDARD" or "EXTENDED"
#   }

#   # Zonal Shift Configuration
#   zonal_shift_config {
#     enabled = each.value.zonal_shift_config_enabled # Can be true or false
#   }

#   tags = merge(
#     { terraform-aws-modules = "eks" },
#     each.value.tags
#   )

#   timeouts {
#     create = try(each.value.cluster_timeouts_create, null)
#     update = try(each.value.cluster_timeouts_update, null)
#     delete = try(each.value.cluster_timeouts_delete, null)
#   }

#   depends_on = [aws_iam_role.eks_cluster_role]


#   lifecycle {
#     ignore_changes = []
#   }
# }
