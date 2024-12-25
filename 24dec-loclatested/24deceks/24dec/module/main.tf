# resource "aws_eks_cluster" "this" {
#   for_each = var.ekscluster

#   name                          = each.value.cluster_name
#   role_arn                      = aws_iam_role.eks_cluster_role.arn
#   version                       = each.value.cluster_version
#   enabled_cluster_log_types     = each.value.cluster_enabled_log_types
#   bootstrap_self_managed_addons = each.value.bootstrap_self_managed_addons

#   access_config {
#     authentication_mode                         = each.value.authentication_mode
#     bootstrap_cluster_creator_admin_permissions = each.value.bootstrap_cluster_creator_admin_permissions
#   }

#   vpc_config {
#     #vpc_id                  = each.value.vpc_id
#     security_group_ids      = aws_security_group.eks_sg.id
#     subnet_ids              = each.value.subnet_ids
#     endpoint_private_access = try(each.value.cluster_endpoint_private_access, true)
#     endpoint_public_access  = try(each.value.cluster_endpoint_public_access, false)
#     public_access_cidrs     = each.value.cluster_endpoint_public_access_cidrs
#   }

#   dynamic "kubernetes_network_config" {
#     for_each = each.value.enable_kubernetes_network_config ? [1] : []

#     content {
#       ip_family         = each.value.cluster_ip_family
#       service_ipv4_cidr = each.value.cluster_service_ipv4_cidr
#       #service_ipv6_cidr = each.value.cluster_service_ipv6_cidr
#     }
#   }

#   #   dynamic "encryption_config" {
#   #     for_each = each.value.enable_cluster_encryption_config ? [1] : []

#   #     content {
#   #       provider {
#   #         key_arn = each.value.create_kms_key ? module.kms.key_arn : each.value.cluster_encryption_config.provider_key_arn
#   #       }
#   #       resources = each.value.cluster_encryption_config.resources
#   #     }
#   #   }

#   # dynamic "encryption_config" {
#   #   for_each = each.value.enable_cluster_encryption_config ? [1] : []

#   #   content {
#   #     provider {
#   #       key_arn = try(each.value.create_kms_key, false) ? module.kms.key_arn : lookup(each.value, "cluster_encryption_config.provider_key_arn", null)
#   #     }
#   #     resources = each.value.cluster_encryption_config.resources
#   #   }
#   # }

#   #   dynamic "upgrade_policy" {
#   #     for_each = each.value.enable_upgrade_policy ? [1] : []

#   #     content {
#   #       max_unavailable = each.value.upgrade_max_unavailable
#   #     }
#   #   }

#   #   dynamic "zonal_shift_config" {
#   #     for_each = each.value.enable_zonal_shift ? [1] : []

#   #     content {
#   #       enabled = each.value.zonal_shift_enabled
#   #       zone    = each.value.zonal_shift_zone
#   #     }
#   #   }

#   tags = merge(
#     { terraform-aws-modules = "eks" },
#     each.value.tags,
#     var.cluster_tags,
#   )

#   timeouts {
#     create = try(each.value.cluster_timeouts.create, "30m") # Default timeout
#     update = try(each.value.cluster_timeouts.update, "30")  # Default timeout
#     delete = try(each.value.cluster_timeouts.delete, "30m") # Default timeout
#   }

#   depends_on = [
#     # aws_iam_role_policy_attachment.this,
#     # aws_security_group_rule.cluster,
#     aws_security_group.eks_sg,
#     aws_iam_role.eks_cluster_role
#   ]

#   lifecycle {
#     ignore_changes = [
#       access_config[0].bootstrap_cluster_creator_admin_permissions
#     ]
#   }
# }






# # ###############

# # module "eks_cluster" {
# #   source = "./eks-cluster"

# #   ekscluster = {
# #     "cluster1" = {
# #       cluster_name                    = "cluster1"
# #       cluster_version                 = "1.21"
# #       cluster_enabled_log_types       = ["api", "audit"]
# #       bootstrap_self_managed_addons   = false
# #       authentication_mode             = "AWS_IAM"
# #       security_group_ids              = ["sg-12345"]
# #       subnet_ids                      = ["subnet-abcde"]
# #       cluster_endpoint_private_access = true
# #       cluster_endpoint_public_access  = true
# #       cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
# #       enable_kubernetes_network_config = true
# #       cluster_ip_family               = "IPv4"
# #       cluster_service_ipv4_cidr       = "10.100.0.0/16"
# #       cluster_service_ipv6_cidr       = "fd00:abcd:1234::/56"
# #       enable_cluster_encryption_config = true
# #       create_kms_key                  = true
# #       cluster_encryption_config = {
# #         provider_key_arn = "arn:aws:kms:region:account-id:key/key-id"
# #         resources        = ["secrets", "configmaps"]
# #       }
# #       enable_upgrade_policy           = true
# #       upgrade_max_unavailable         = 1
# #       enable_zonal_shift              = true
# #       zonal_shift_enabled             = true
# #       zonal_shift_zone                = "us-west-2a"
# #       tags                            = { "Environment" = "Production" }
# #       cluster_timeouts = {
# #         create = "30m"
# #         update = "20m"
# #         delete = "15m"
# #       }
# #     },
# #     "cluster2" = {
# #       cluster_name                    = "cluster2"
# #       cluster_version                 = "1.22"
# #       cluster_enabled_log_types       = ["api"]
# #       bootstrap_self_managed_addons   = true
# #       authentication_mode             = "OIDC"
# #       security_group_ids              = ["sg-67890"]
# #       subnet_ids                      = ["subnet-fghij"]
# #       cluster_endpoint_private_access = false
# #       cluster_endpoint_public_access  = true
# #       cluster_endpoint_public_access_cidrs = ["192.168.1.0/24"]
# #       enable_kubernetes_network_config = false
# #       cluster_ip_family               = "IPv6"
# #       cluster_service_ipv4_cidr       = "10.101.0.0/16"
# #       cluster_service_ipv6_cidr       = "fd00:abcd:5678::/56"
# #       enable_cluster_encryption_config = false
# #       create_kms_key                  = false
# #       cluster_encryption_config = {}
# #       enable_upgrade_policy           = false
# #       upgrade_max_unavailable         = 0
# #       enable_zonal_shift              = false
# #       zonal_shift_enabled             = false
# #       zonal_shift_zone                = ""
# #       tags                            = { "Environment" = "Staging" }
# #       cluster_timeouts = {
# #         create = "30m"
# #         update = "20m"
# #         delete = "15m"
# #       }
# #     }
# #   }

# #   cluster_tags = {
# #     "project" = "example"
# #     "team"    = "devops"
# #   }
# # }

# # output "eks_cluster_arns" {
# #   description = "The ARNs of the created EKS clusters"
# #   value       = module.eks_cluster.eks_cluster_arns
# # }
