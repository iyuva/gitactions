####################################
## IAM Variables
####################################

variable "default_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Project"     = "eks-cluster"
  }
}

variable "cluster_names" {
  description = "Map of cluster names and configurations"
  type = map(object({
    version                     = string
    enabled_log_types           = list(string)
    bootstrap_addons            = bool
    authentication_mode         = string
    cluster_creator_permissions = bool
    subnet_ids                  = list(string)
    security_group_ids          = list(string)
    endpoint_private_access     = bool
    endpoint_public_access      = bool
    public_access_cidrs         = list(string)
    cluster_timeouts = object({
      create = string
      update = string
      delete = string
    })
  }))
  default = {}
}

# variable "vpc_id" {
#   description = "VPC ID where the EKS cluster will be deployed"
#   type        = string
#   default     = "vpc-xxxxxx"
# }

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
  default     = ["subnet-xxxxxx", "subnet-yyyyyy"]
}

# variable "security_group_rules" {
#   description = "List of security group rules for the EKS control plane"
#   type = map(object({
#     protocol                 = string
#     from_port                = number
#     to_port                  = number
#     type                     = string
#     description              = optional(string)
#     cidr_blocks              = optional(list(string))
#     ipv6_cidr_blocks         = optional(list(string))
#     prefix_list_ids          = optional(list(string))
#     self                     = optional(bool)
#     source_security_group_id = optional(string)
#   }))
#   default = {}
# }

# # Declare the vpc_id variable
# variable "vpc_id" {
#   description = "The ID of the VPC in which to create the security group"
#   type        = string
# }

# # Declare the default_tags variable
# variable "default_tags" {
#   description = "Default tags to apply to all resources"
#   type        = map(string)
#   default = {
#     "Environment" = "Production"
#     "Owner"       = "Team XYZ"
#   }
# }

# Declare the cluster_security_group_tags variable
variable "cluster_security_group_tags" {
  description = "Additional tags specific to the EKS cluster security group"
  type        = map(string)
  default = {
    "Cluster" = "MyEKSCluster"
  }
}




# variable "eks_addons" {
#   description = "Map of EKS Addons configurations"
#   type = map(object({
#     addon_name           = string
#     addon_version        = string
#     configuration_values = map(string)
#     pod_identity_association = optional(object({
#       service_account = string
#     }))
#     preserve                    = optional(bool, true)
#     resolve_conflicts_on_create = optional(string, "OVERWRITE")
#     resolve_conflicts_on_update = optional(string, "OVERWRITE")
#     service_account_role_arn    = optional(string)
#     timeouts = object({
#       create = string
#       update = string
#       delete = string
#     })
#     tags = optional(map(string))
#   }))
#   default = {}
# }

variable "eks_addons" {
  description = "Map of EKS addon configurations"
  type = map(object({
    addon_name                  = string
    addon_version               = string
    configuration_values        = map(string)
    service_account_role_arn    = string
    preserve                    = bool
    resolve_conflicts_on_create = string
    resolve_conflicts_on_update = string
  }))
  default = {
    "vpc-cni" = {
      addon_name    = "vpc-cni"
      addon_version = "v1.11.5-eksbuild.1"
      configuration_values = {
        "eniConfig" = "true"
      }
      service_account_role_arn    = "arn:aws:iam::123456789012:role/eks-addon-vpc-cni-role"
      preserve                    = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    },
    "coredns" = {
      addon_name                  = "coredns"
      addon_version               = "v1.8.4-eksbuild.1"
      configuration_values        = {}
      service_account_role_arn    = "arn:aws:iam::123456789012:role/eks-addon-coredns-role"
      preserve                    = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }
}


variable "eks_identity_provider_configs" {
  description = "Map of EKS identity provider configurations"
  type = map(object({
    client_id                     = string
    groups_claim                  = optional(string)
    groups_prefix                 = optional(string)
    identity_provider_config_name = string
    issuer_url                    = optional(string)
    required_claims               = optional(list(string))
    username_claim                = optional(string)
    username_prefix               = optional(string)
    tags                          = optional(map(string))
  }))
  default = {}
}

####################################
## Validation Examples
####################################

# Validate VPC ID follows the correct format for AWS VPC IDs
variable "vpc_id" {
  description = "VPC ID for the EKS Cluster"
  type        = string
  # validation {
  #   condition     = length(var.vpc_id) == 12 && substr(var.vpc_id, 0, 4) == "vpc-"
  #   error_message = "VPC ID must be in the format vpc-xxxxxxxxxxxx"
  # }
}

# Validate that security group rules are correctly configured
variable "security_group_rules" {
  description = "Security group rules for the EKS control plane"
  type = map(object({
    protocol  = string
    from_port = number
    to_port   = number
    type      = string
  }))
  validation {
    condition = alltrue([
      for rule in values(var.security_group_rules) :
      rule.protocol == "tcp" || rule.protocol == "udp" || rule.protocol == "icmp"
    ])
    error_message = "Security group rule protocols must be tcp, udp, or icmp"
  }
}




##### cluster_ip_family

variable "cluster_ip_family" {
  description = "The IP family to use for the Kubernetes cluster (IPv4 or IPv6)"
  type        = string
  default     = "IPv4" # Default to IPv4, can be changed to "IPv6"
  validation {
    condition     = contains(["ipv4", "ipv6"], var.cluster_ip_family)
    error_message = "cluster_ip_family must be either 'IPv4' or 'IPv6'."
  }
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to use for the Kubernetes services in IPv4"
  type        = string
  default     = "10.100.0.0/16" # Default CIDR block for IPv4 services
  validation {
    condition     = can(cidrsubnet(var.cluster_service_ipv4_cidr, 8, 1))
    error_message = "cluster_service_ipv4_cidr must be a valid IPv4 CIDR block."
  }
}

variable "cluster_service_ipv6_cidr" {
  description = "The CIDR block to use for the Kubernetes services in IPv6"
  type        = string
  default     = "fd00::/80" # Default CIDR block for IPv6 services
  validation {
    condition     = can(cidrsubnet(var.cluster_service_ipv6_cidr, 8, 1))
    error_message = "cluster_service_ipv6_cidr must be a valid IPv6 CIDR block."
  }
}




###### outpost

variable "outpost_config" {
  description = "Outpost configuration for the EKS cluster"
  type = object({
    control_plane_instance_type = string
    outpost_arns                = list(string)
  })
  default = null

  validation {
    condition = (
      var.outpost_config == null ||
      (
        length(var.outpost_config.outpost_arns) > 0 &&
        var.outpost_config.control_plane_instance_type != ""
      )
    )
    error_message = "If outpost_config is provided, outpost_arns and control_plane_instance_type must be specified."
  }
}

#  EX for outpost 
# outpost_config = {
#   control_plane_instance_type = "r5.large"
#   outpost_arns                = ["arn:aws:outposts:us-west-2:123456789012:outpost/op-123abc456def"]
# }




##### cluster_encryption_config

variable "cluster_encryption_config" {
  description = "Encryption configuration for the EKS cluster"
  type = object({
    provider_key_arn = string
    resources        = list(string)
  })
  default = null

  validation {
    condition = (
      var.cluster_encryption_config == null ||
      (
        var.cluster_encryption_config.provider_key_arn != "" &&
        length(var.cluster_encryption_config.resources) > 0
      )
    )
    error_message = "If cluster_encryption_config is provided, provider_key_arn and resources must be specified."
  }
}


variable "create_kms_key" {
  description = "Flag to determine if a new KMS key should be created"
  type        = bool
  default     = false
}


# example

# cluster_encryption_config = {
#   provider_key_arn = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-56ef-78gh-90ij-klmn1234opqr"
#   resources        = ["secrets"]
# }

# create_kms_key = false  # Set to true if you want to create a new KMS key



################ cluster upgrade policy 

variable "cluster_upgrade_policy" {
  description = "EKS cluster upgrade policy"
  type = object({
    support_type = string
  })
  default = null

  validation {
    condition = (
      var.cluster_upgrade_policy == null ||
      var.cluster_upgrade_policy.support_type != ""
    )
    error_message = "If cluster_upgrade_policy is provided, support_type must be specified."
  }
}

# example 
# cluster_upgrade_policy = {
#   support_type = "EKS"
# }

############ zonal_shift

variable "cluster_zonal_shift_config" {
  description = "EKS cluster zonal shift configuration"
  type = object({
    enabled = bool
  })
  default = null

  validation {
    condition = (
      var.cluster_zonal_shift_config == null ||
      var.cluster_zonal_shift_config.enabled != null
    )
    error_message = "If cluster_zonal_shift_config is provided, enabled must be specified."
  }
}


# example
# cluster_zonal_shift_config = {
#   enabled = true
# }


####################################
## EKS Access Entry and policy assocaition 
###################################

variable "cluster_access_entries" {
  description = "A map of EKS access entries for granting access to the EKS cluster"
  type = map(object({
    kubernetes_groups = list(string)
    principal_arn     = string
    type              = string
    user_name         = string
    tags              = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for entry in var.cluster_access_entries : entry.kubernetes_groups != []])
    error_message = "Each access entry must have a non-empty list of kubernetes_groups."
  }
}



variable "cluster_access_policy_associations" {
  description = "A map of EKS access policy associations"
  type = map(object({
    namespaces    = list(string)
    type          = string
    policy_arn    = string
    principal_arn = string
    tags          = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for assoc in var.cluster_access_policy_associations : length(assoc.namespaces) > 0])
    error_message = "Each policy association must have at least one namespace."
  }
}





# # Example access entries for the EKS cluster
# cluster_access_entries = {
#   "access_entry_1" = {
#     kubernetes_groups = ["system:masters", "dev:users"]
#     principal_arn     = "arn:aws:iam::123456789012:role/EKSAdmin"
#     type              = "USER"
#     user_name         = "admin-user"
#     tags = {
#       "Environment" = "Production"
#     }
#   },
#   "access_entry_2" = {
#     kubernetes_groups = ["dev:users"]
#     principal_arn     = "arn:aws:iam::123456789012:user/dev-user"
#     type              = "USER"
#     user_name         = "dev-user"
#   }
# }

# # Example policy associations for the EKS cluster
# cluster_access_policy_associations = {
#   "policy_association_1" = {
#     namespaces     = ["default", "kube-system"]
#     type           = "GROUP"
#     policy_arn     = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#     principal_arn  = "arn:aws:iam::123456789012:role/EKSAdmin"
#     tags = {
#       "Environment" = "Production"
#     }
#   }
# }



# variable "eks_role" {
#   description = "The ARN of the EKS role"
#   type        = string
# }

variable "eks_role" {
  description = "The IAM role for the EKS cluster"
  type        = map(string)
}



