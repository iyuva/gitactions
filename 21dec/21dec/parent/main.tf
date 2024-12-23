module "eks_cluster" {
  source = "C:/Users/venkat/Desktop/New folder (2)/21dec" # Adjust the path if necessary
  vpc_id = var.vpc_id                                     # Pass the VPC ID for the EKS Cluster

  #for_each = var.eks_clusters
  #eks_clusters = var.eks_cluster
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  cluster_enabled_log_types = var.cluster_enabled_log_types
  #authentication_mode             = var.cluster_authentication_mode
  #bootstrap_cluster_creator_admin_permissions = var.cluster_bootstrap_cluster_creator_admin_permissions
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  # cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  subnet_ids                = var.cluster_subnet_ids
  cluster_ip_family         = var.cluster_ip_family
  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr
  #cluster_service_ipv6_cidr       = var.cluster_service_ipv6_cidr
  #upgrade_policy_support_type     = var.cluster_upgrade_policy_support_type
  #zonal_shift_config_enabled      = var.cluster_zonal_shift_config_enabled
  #tags                            = var.cluster_tags
  cluster_timeouts_create = var.cluster_timeouts_create
  cluster_timeouts_update = var.cluster_timeouts_update
  cluster_timeouts_delete = var.cluster_timeouts_delete
}









# module "eks_cluster" {
#   source = "./modules/eks_cluster" # Path to your module

#   eks_clusters = var.eks_clusters # Reference the eks_clusters variable

#   # Pass any additional variables to the module as required:
#   #region                            = var.region
#   cluster_name                                = var.cluster_name
#   cluster_version                             = var.cluster_version
#   cluster_enabled_log_types                   = var.cluster_enabled_log_types
#   bootstrap_self_managed_addons               = var.bootstrap_self_managed_addons
#   authentication_mode                         = var.authentication_mode
#   bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
#   cluster_endpoint_private_access             = var.cluster_endpoint_private_access
#   cluster_endpoint_public_access              = var.cluster_endpoint_public_access
#   cluster_endpoint_public_access_cidrs        = var.cluster_endpoint_public_access_cidrs
#   subnet_ids                                  = var.subnet_ids
#   cluster_ip_family                           = var.cluster_ip_family
#   cluster_service_ipv4_cidr                   = var.cluster_service_ipv4_cidr
#   upgrade_policy_support_type                 = var.cluster_upgrade_policy_support_type
#   zonal_shift_config_enabled                  = var.zonal_shift_config_enabled
#   # encryption_config_key_arn         = var.encryption_config_key_arn
#   # encryption_config_resources       = var.encryption_config_resources
#   # logging_enabled                    = var.logging_enabled
#   # logging_types                      = var.logging_types
#   # identity_provider_name            = var.identity_provider_name
#   # identity_provider_type            = var.identity_provider_type
#   # oidc_issuer_url                   = var.oidc_issuer_url
#   # oidc_client_id                    = var.oidc_client_id
#   # oidc_client_secret                = var.oidc_client_secret
#   # oidc_username_claim               = var.oidc_username_claim
#   # oidc_username_prefix              = var.oidc_username_prefix
#   # api_server_access_enabled         = var.api_server_access_enabled
#   # api_server_access_cidr_blocks     = var.api_server_access_cidr_blocks
#   # compute_cpu                        = var.compute_cpu
#   # compute_memory                     = var.compute_memory
#   #tags                               = var.tags
#   cluster_timeouts_create = var.cluster_timeouts_create
#   cluster_timeouts_update = var.cluster_timeouts_update
#   cluster_timeouts_delete = var.cluster_timeouts_delete
# }
