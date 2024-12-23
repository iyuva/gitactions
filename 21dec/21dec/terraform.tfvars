# # Define the VPC ID for EKS Cluster
# vpc_id = "vpc-0f3bd8a991ae9fcfe"

# # Define EKS Clusters configuration
# eks_clusters = {
#   #   "cluster" = {
#   cluster_name                                = "cluster1"
#   cluster_version                             = "1.31"
#   cluster_enabled_log_types                   = ["api", "audit", "authenticator"]
#   bootstrap_self_managed_addons               = false
#   authentication_mode                         = "API"
#   bootstrap_cluster_creator_admin_permissions = true
#   cluster_endpoint_private_access             = true
#   cluster_endpoint_public_access              = false
#   cluster_endpoint_public_access_cidrs        = ["0.0.0.0/0"]
#   subnet_ids                                  = ["subnet-0c95b4890ff609ed2", "subnet-0f740eebaa0b4cda3"]
#   cluster_ip_family                           = "ipv4"
#   cluster_service_ipv4_cidr                   = "10.100.0.0/16"
#   cluster_service_ipv6_cidr                   = "fd00::/64"
#   upgrade_policy_support_type                 = "EXTENDED"
#   zonal_shift_config_enabled                  = false
#   tags = {
#     "Environment" = "Production"
#     "Owner"       = "Team1"
#   }

#   cluster_timeouts_create = "45m"
#   cluster_timeouts_update = "30m"
#   cluster_timeouts_delete = "30m"
#   #   },
# }
