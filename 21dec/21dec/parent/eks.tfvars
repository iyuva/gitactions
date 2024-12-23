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


# vpc_id = "vpc-0f3bd8a991ae9fcfe" # Replace with your actual VPC ID

# #########################
# Define the VPC ID for EKS Cluster
#vpc_id = "vpc-0907878a67d69f16a" # Replace with your actual VPC ID 	


# EKS Cluster Configuration
# default = {
#     "cluster_1" = {
# cluster_name                                        = "my-cluster"
# cluster_version                                     = "1.31" # Replace with the desired Kubernetes version
# cluster_enabled_log_types                           = ["api", "audit", "authenticator"]
# cluster_bootstrap_self_managed_addons               = true
# cluster_authentication_mode                         = "API"
# cluster_bootstrap_cluster_creator_admin_permissions = true

# # Cluster Endpoint Configuration
# cluster_endpoint_private_access      = true
# cluster_endpoint_public_access       = true
# cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]                                            # Update with appropriate CIDR blocks
# cluster_subnet_ids                   = ["subnet-05df11a4818050847", "subnet-08a705a45e7711415"] # Replace with your subnet IDs

# # Networking Configuration
# cluster_ip_family         = "ipv4"
# cluster_service_ipv4_cidr = "10.100.0.0/16" # Example CIDR block
# #cluster_service_ipv6_cidr = "fd00:100::/56" # Example CIDR block

# # Upgrade Policy Configuration
# cluster_upgrade_policy_support_type = "EXTENDED"

# # Zonal Shift Configuration
# cluster_zonal_shift_config_enabled = false

# # Tags for the Cluster
# cluster_tags = {
#   "Environment" = "production"
#   "Project"     = "eks-cluster"
# }
# # Timeouts for Cluster Operations
# cluster_timeouts_create = "30m" # Timeout for creating the cluster
# cluster_timeouts_update = "20m" # Timeout for updating the cluster
# cluster_timeouts_delete = "15m" # Timeout for deleting the cluster

#   }
# }


#  default = {
#     "cluster_1" = {
vpc_id = "vpc-00cbb15d379c40ca2"
eks_clusters = {
  "default" = {


    cluster_name                                = "my-cluster"
    cluster_version                             = "1.31" # Replace with the desired Kubernetes version
    cluster_enabled_log_types                   = ["api", "audit", "authenticator"]
    bootstrap_self_managed_addons               = true
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true

    # Cluster Endpoint Configuration
    cluster_endpoint_private_access      = true
    cluster_endpoint_public_access       = true
    cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]                                            # Update with appropriate CIDR blocks
    subnet_ids                           = ["subnet-0af957b795ca5ddb7", "subnet-007ba27762622945b"] # Replace with your subnet IDs

    # Networking Configuration
    cluster_ip_family         = "ipv4"
    cluster_service_ipv4_cidr = "10.100.0.0/16" # Example CIDR block
    #cluster_service_ipv6_cidr             = "fd00:100::/56"  # Example CIDR block (optional)

    # Upgrade Policy Configuration
    cluster_upgrade_policy_support_type = "EXTENDED"

    # Zonal Shift Configuration
    cluster_zonal_shift_config_enabled = false

    # Tags for the Cluster
    cluster_tags = {
      "Environment" = "production"
      "Project"     = "eks-cluster"
    }
  }
}
