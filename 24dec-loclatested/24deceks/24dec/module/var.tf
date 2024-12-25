
############
variable "ekscluster" {
  description = "Map of EKS clusters to create"
  type = map(object({
    cluster_name                  = string
    cluster_version               = string
    cluster_enabled_log_types     = list(string)
    bootstrap_self_managed_addons = bool
    authentication_mode           = string
    #security_group_ids                          = list(string)
    subnet_ids                                  = list(string)
    cluster_endpoint_private_access             = bool
    cluster_endpoint_public_access              = bool
    cluster_endpoint_public_access_cidrs        = list(string)
    bootstrap_cluster_creator_admin_permissions = bool
    enable_kubernetes_network_config            = bool
    cluster_ip_family                           = string
    cluster_service_ipv4_cidr                   = string
    #cluster_service_ipv6_cidr                   = string
    enable_cluster_encryption_config = string
    # create_kms_key                              = bool
    # cluster_encryption_config = object({
    #   provider_key_arn = string
    #   resources        = list(string)
    # })
    enable_upgrade_policy = any #string
    # upgrade_max_unavailable = number
    enable_zonal_shift = bool
    #zonal_shift_enabled     = bool
    # zonal_shift_zone        = string
    tags = map(string)
    cluster_timeouts = object({
      create = string
      update = string
      delete = string
    })
  }))
}

variable "cluster_tags" {
  description = "Tags to be applied to the clusters"
  type        = map(string)
  default     = {}
}
variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
  default     = null
}

# Define the variable for EKS cluster name
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "" # Default value can be overridden by the user
}

variable "region" {
  type    = string
  default = "us-east-1"
}
