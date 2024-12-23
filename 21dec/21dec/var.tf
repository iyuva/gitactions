##########
#NEW
##########
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  #default     = ""

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "Cluster name cannot be empty."
  }
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.30`)"
  type        = string
  #default     = null

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
    error_message = "Cluster version must follow the format <major>.<minor>, for example '1.30'."
  }
}

# variable "eks_clusters" {
#   description = "A map of EKS cluster configurations"
#   type = map(object({
#     cluster_name                                = string
#     cluster_version                             = string
#     cluster_enabled_log_types                   = list(string)
#     bootstrap_self_managed_addons               = bool
#     authentication_mode                         = string
#     bootstrap_cluster_creator_admin_permissions = bool
#     cluster_endpoint_private_access             = bool
#     cluster_endpoint_public_access              = bool
#     cluster_endpoint_public_access_cidrs        = list(string)
#     subnet_ids                                  = list(string)
#     cluster_ip_family                           = string
#     cluster_service_ipv4_cidr                   = string
#     cluster_service_ipv6_cidr                   = string
#     upgrade_policy_support_type                 = string
#     zonal_shift_config_enabled                  = bool
#     tags                                        = map(string)
#     cluster_timeouts_create                     = string
#     cluster_timeouts_update                     = string
#     cluster_timeouts_delete                     = string
#   }))
#   default = {}

#   validation {
#     condition     = alltrue([for cluster in var.eks_clusters : length(cluster.cluster_name) > 0])
#     error_message = "Cluster names cannot be empty."
#   }
# }

variable "eks_clusters" {
  description = "A map of EKS cluster configurations"

  type = map(object({
    # The name of the EKS cluster. This is a required string that uniquely identifies the cluster.
    cluster_name = string

    # The Kubernetes version of the EKS cluster. Determines which Kubernetes features and APIs are available to the cluster.
    cluster_version = string

    # A list of enabled log types for the EKS cluster, such as `api`, `audit`, `authenticator`, etc. These are important for monitoring and troubleshooting.
    cluster_enabled_log_types = list(string)

    # Determines if self-managed addons are bootstrapped for the EKS cluster. If `true`, the cluster will use self-managed addons.
    bootstrap_self_managed_addons = bool

    # Specifies the authentication mode for the EKS cluster. Possible values might include `AWS`, `kubectl`, or `OIDC`.
    authentication_mode = string

    # Controls whether the creator of the EKS cluster will have admin permissions for managing the cluster.
    bootstrap_cluster_creator_admin_permissions = bool

    # Determines if the EKS cluster's API endpoint is only accessible from within the VPC (private access). If `true`, the endpoint is restricted to the private network.
    cluster_endpoint_private_access = bool

    # Indicates if the EKS cluster's API endpoint is accessible from outside the VPC (public access). If `true`, the endpoint is accessible from the public internet.
    cluster_endpoint_public_access = bool

    # A list of CIDR blocks that define which external IP ranges can access the public endpoint of the EKS cluster if `cluster_endpoint_public_access` is `true`.
    cluster_endpoint_public_access_cidrs = list(string)

    # A list of subnet IDs within the VPC where the EKS cluster's worker nodes will be deployed. These can be public or private subnets.
    subnet_ids = list(string)

    # Specifies the IP family used by the EKS cluster (either `ipv4` or `ipv6`). Determines the IP addressing scheme for the cluster's networking.
    cluster_ip_family = string

    # The IPv4 CIDR block used by the EKS cluster for its service network. Defines the range of IP addresses for Kubernetes services.
    cluster_service_ipv4_cidr = string

    # The IPv6 CIDR block used by the EKS cluster for its service network, similar to `cluster_service_ipv4_cidr` but for IPv6 addresses.
    #cluster_service_ipv6_cidr = string

    # Defines the upgrade policy for the EKS cluster, such as `RollingUpdate` or `BlueGreen`.
    upgrade_policy_support_type = string

    # A boolean indicating whether the zonal shift configuration is enabled for the cluster. Zonal shifts balance node groups across availability zones for redundancy.
    zonal_shift_config_enabled = bool

    # A map of tags associated with the EKS cluster. Tags are key-value pairs for identification, cost allocation, or organizational purposes.
    tags = map(string)

    # Specifies the timeout duration for creating the EKS cluster. Controls how long Terraform should wait for the cluster to be created before timing out.
    cluster_timeouts_create = string

    # Specifies the timeout duration for updating the EKS cluster. Defines how long Terraform should wait before timing out during an update.
    cluster_timeouts_update = string

    # Specifies the timeout duration for deleting the EKS cluster. Defines how long Terraform should wait before timing out when deleting the cluster.
    cluster_timeouts_delete = string
  }))

  # Default value for the `eks_clusters` variable. It is an empty map by default.
  default = {}

  # Validation to ensure that all cluster names are non-empty.
  validation {
    condition     = alltrue([for cluster in var.eks_clusters : length(cluster.cluster_name) > 0])
    error_message = "Cluster names cannot be empty."
  }
}


variable "vpc_id" {
  description = "The ID of the VPC to deploy resources into."
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "VPC ID cannot be empty."
  }
}



variable "cluster_timeouts_create" {
  description = "Timeout for creating the EKS cluster"
  type        = string
  default     = "30m"

  validation {
    condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_create))
    error_message = "Cluster timeout for creation must be a valid duration (e.g., 30m, 1h)."
  }
}

variable "cluster_timeouts_update" {
  description = "Timeout for updating the EKS cluster"
  type        = string
  default     = "30m"

  validation {
    condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_update))
    error_message = "Cluster timeout for update must be a valid duration (e.g., 30m, 1h)."
  }
}

variable "cluster_timeouts_delete" {
  description = "Timeout for deleting the EKS cluster"
  type        = string
  default     = "30m"

  validation {
    condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_delete))
    error_message = "Cluster timeout for deletion must be a valid duration (e.g., 30m, 1h)."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach to the EKS cluster"
  type        = list(string)
  #default     = []

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be specified."
  }
}


variable "cluster_enabled_log_types" {
  description = "List of enabled log types for the EKS cluster"
  type        = list(string)
  #default     = []

  validation {
    condition     = alltrue([for log_type in var.cluster_enabled_log_types : contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)])
    error_message = "Log types must be one of: api, audit, authenticator, controllerManager, scheduler."
  }
}



variable "cluster_ip_family" {
  description = "IP family for the EKS cluster"
  type        = string
  #default     = "IPv4"

  validation {
    condition     = var.cluster_ip_family == "ipv4" || var.cluster_ip_family == "ipv6"
    error_message = "Cluster IP family must be either 'ipv4' or 'ipv6'."
  }
}

variable "cluster_service_ipv4_cidr" {
  description = "IPv4 CIDR block for the EKS cluster's service network"
  type        = string
  default     = "10.100.0.0/16"

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/(\\d{1,2})$", var.cluster_service_ipv4_cidr))
    error_message = "Cluster service IPv4 CIDR must be a valid CIDR block, e.g., '10.100.0.0/16'."
  }
}

# variable "cluster_service_ipv6_cidr" {
#   description = "IPv6 CIDR block for the EKS cluster's service network"
#   type        = string
#   default     = null

#   validation {
#     condition     = can(regex("^\\[([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}]\\/(\\d{1,3})$", var.cluster_service_ipv6_cidr)) || var.cluster_service_ipv6_cidr == null
#     error_message = "Cluster service IPv6 CIDR must be a valid CIDR block, e.g., '[2001:db8::1]/64'."
#   }
# }

variable "cluster_endpoint_private_access" {
  description = "Whether private access to the EKS cluster endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Whether public access to the EKS cluster endpoint is enabled"
  type        = bool
  default     = false
}




################
