variable "vpc_id" {
  description = "The ID of the VPC in which to create the EKS cluster"
  type        = string
}

# variable "eks_cluster" {
#   description = "MAP of EKS cluster "
#   type        = map(any)
# }
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
}

variable "cluster_enabled_log_types" {
  description = "List of enabled log types for the EKS cluster"
  type        = list(string)
}

variable "cluster_bootstrap_self_managed_addons" {
  description = "Whether to enable self-managed addons for the EKS cluster"
  type        = bool
}

variable "cluster_authentication_mode" {
  description = "The authentication mode for the EKS cluster"
  type        = string
}

variable "cluster_bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to grant cluster creator admin permissions"
  type        = bool
}

variable "cluster_endpoint_private_access" {
  description = "Whether to enable private access to the cluster endpoint"
  type        = bool
}

variable "cluster_endpoint_public_access" {
  description = "Whether to enable public access to the cluster endpoint"
  type        = bool
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDRs that are allowed for public access to the cluster endpoint"
  type        = list(string)
}

variable "cluster_subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_ip_family" {
  description = "The IP family for the EKS cluster"
  type        = string
}

variable "cluster_service_ipv4_cidr" {
  description = "The IPv4 CIDR block for the EKS cluster"
  type        = string
}

# variable "cluster_service_ipv6_cidr" {
#   description = "The IPv6 CIDR block for the EKS cluster"
#   type        = string
# }

variable "cluster_upgrade_policy_support_type" {
  description = "The upgrade policy support type for the EKS cluster"
  type        = string
}

variable "cluster_zonal_shift_config_enabled" {
  description = "Whether zonal shift configuration is enabled"
  type        = bool
}

variable "cluster_tags" {
  description = "Tags for the EKS cluster"
  type        = map(string)
}

variable "cluster_timeouts_create" {
  description = "Timeout for creating the EKS cluster"
  type        = string
}

variable "cluster_timeouts_update" {
  description = "Timeout for updating the EKS cluster"
  type        = string
}

variable "cluster_timeouts_delete" {
  description = "Timeout for deleting the EKS cluster"
  type        = string
}


variable "eks_clusters" {
  description = "A map of EKS cluster configurations."
  type = map(object({
    cluster_name                                = string
    cluster_version                             = string
    cluster_enabled_log_types                   = list(string)
    bootstrap_self_managed_addons               = bool
    authentication_mode                         = string
    bootstrap_cluster_creator_admin_permissions = bool
    cluster_endpoint_private_access             = bool
    cluster_endpoint_public_access              = bool
    cluster_endpoint_public_access_cidrs        = list(string)
    subnet_ids                                  = list(string)
    cluster_ip_family                           = string
    cluster_service_ipv4_cidr                   = string
    upgrade_policy_support_type                 = string
    zonal_shift_config_enabled                  = bool
    tags                                        = map(string)
  }))
}
