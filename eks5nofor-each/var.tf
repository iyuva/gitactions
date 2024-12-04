#######################
# IAM Resources
#######################

variable "eks_role_name" {
  description = "The name of the EKS IAM Role"
  type        = string
  default     = "eks-role"

  validation {
    condition     = length(var.eks_role_name) > 0
    error_message = "The EKS IAM role name cannot be empty."
  }
}

variable "eks_policy_name" {
  description = "The name of the EKS IAM Policy"
  type        = string
  default     = "eks-policy"

  validation {
    condition     = length(var.eks_policy_name) > 0
    error_message = "The EKS IAM policy name cannot be empty."
  }
}

variable "eks_policy_description" {
  description = "Description for the EKS IAM Policy"
  type        = string
  default     = "Policy for managing EKS cluster and associated resources"

  validation {
    condition     = length(var.eks_policy_description) > 0
    error_message = "The EKS IAM policy description cannot be empty."
  }
}

variable "default_tags" {
  description = "Default tags to apply to resources"
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Team"        = "ops"
  }
}

#######################
# EKS Cluster
#######################

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "The EKS cluster name cannot be empty."
  }
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.21"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
    error_message = "The cluster version must be in the format x.y (e.g., 1.21)."
  }
}

variable "enabled_log_types" {
  description = "The enabled log types for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]

  validation {
    condition     = length(var.enabled_log_types) > 0
    error_message = "At least one log type must be enabled."
  }
}

variable "bootstrap_addons" {
  description = "A boolean value that determines if self-managed bootstrap addons should be enabled"
  type        = bool
  default     = true
}

variable "authentication_mode" {
  description = "Authentication mode for the EKS cluster"
  type        = string
  default     = "RBAC"

  validation {
    condition     = contains(["RBAC", "OIDC"], var.authentication_mode)
    error_message = "Authentication mode must be either 'RBAC' or 'OIDC'."
  }
}

variable "cluster_creator_permissions" {
  description = "If true, grants cluster creator admin permissions"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the EKS cluster"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

variable "endpoint_private_access" {
  description = "Boolean indicating if the EKS cluster API server endpoint should be accessible from within the VPC"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Boolean indicating if the EKS cluster API server endpoint should be publicly accessible"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks for public access to the EKS cluster API server"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.public_access_cidrs) > 0
    error_message = "At least one public access CIDR block must be specified."
  }
}

variable "cluster_ip_family" {
  description = "The IP family for the EKS cluster (IPv4 or dual-stack)"
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack"], var.cluster_ip_family)
    error_message = "Cluster IP family must be either 'ipv4' or 'dualstack'."
  }
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block for the cluster's service IP range"
  type        = string
  default     = "10.100.0.0/16"

  validation {
    condition     = can(regex("^(10|172|192)\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\/\\d{1,2}$", var.cluster_service_ipv4_cidr))
    error_message = "The CIDR block must be a valid IPv4 address range (e.g., 10.100.0.0/16)."
  }
}

variable "cluster_upgrade_policy" {
  description = "The upgrade policy for the EKS cluster"
  type        = string
  default     = "ACTIVE"

  validation {
    condition     = contains(["ACTIVE", "NONE"], var.cluster_upgrade_policy)
    error_message = "The upgrade policy must be either 'ACTIVE' or 'NONE'."
  }
}

variable "cluster_zonal_shift_enabled" {
  description = "If true, enables zonal shift for the EKS cluster"
  type        = bool
  default     = false
}

variable "cluster_timeouts" {
  description = "Timeout configuration for EKS cluster creation, update, and deletion"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  validation {
    condition     = can(regex("^\\d{1,2}[hms]$", var.cluster_timeouts.create))
    error_message = "The timeout value for 'create' must be in a valid format (e.g., '60m', '1h')."
  }
}

#######################
# Security Groups for EKS Cluster
#######################

variable "eks_security_group_name" {
  description = "The name of the security group for EKS Control Plane"
  type        = string
  default     = "eks-control-plane-sg"

  validation {
    condition     = length(var.eks_security_group_name) > 0
    error_message = "The security group name cannot be empty."
  }
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "The VPC ID cannot be empty."
  }
}

variable "security_group_protocol" {
  description = "The protocol for security group rules"
  type        = string
  default     = "tcp"

  validation {
    condition     = contains(["tcp", "udp", "icmp"], var.security_group_protocol)
    error_message = "The security group protocol must be either 'tcp', 'udp', or 'icmp'."
  }
}

variable "security_group_from_port" {
  description = "The starting port for security group rules"
  type        = number
  default     = 443

  validation {
    condition     = var.security_group_from_port >= 0 && var.security_group_from_port <= 65535
    error_message = "The starting port must be a valid number between 0 and 65535."
  }
}

variable "security_group_to_port" {
  description = "The ending port for security group rules"
  type        = number
  default     = 443

  validation {
    condition     = var.security_group_to_port >= 0 && var.security_group_to_port <= 65535
    error_message = "The ending port must be a valid number between 0 and 65535."
  }
}

variable "security_group_type" {
  description = "The type of security group rule"
  type        = string
  default     = "ingress"

  validation {
    condition     = contains(["ingress", "egress"], var.security_group_type)
    error_message = "The security group type must be either 'ingress' or 'egress'."
  }
}

variable "security_group_description" {
  description = "Description for the security group rule"
  type        = string
  default     = "Allow ingress for EKS control plane"
}

variable "security_group_cidr_blocks" {
  description = "List of CIDR blocks for security group ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.security_group_cidr_blocks) > 0
    error_message = "At least one CIDR block must be specified for the security group."
  }
}

#######################
# EC2 Tags for EKS Resources
#######################

variable "subnet_name" {
  description = "The name of the subnets"
  type        = string
  default     = "eks-subnet"

  validation {
    condition     = length(var.subnet_name) > 0
    error_message = "The subnet name cannot be empty."
  }
}

#######################
# IAM Roles and Policies for Addons
#######################

variable "addon_names" {
  description = "The names of the EKS addons"
  type        = list(string)

  validation {
    condition     = length(var.addon_names) > 0
    error_message = "At least one addon name must be specified."
  }
}

variable "addon_versions" {
  description = "The versions of the EKS addons"
  type        = map(string)

  validation {
    condition     = length(var.addon_versions) > 0
    error_message = "At least one addon version must be specified."
  }
}

#######################
# OIDC Identity Provider
#######################

variable "oidc_client_id" {
  description = "OIDC client ID for identity provider"
  type        = string

  validation {
    condition     = length(var.oidc_client_id) > 0
    error_message = "The OIDC client ID cannot be empty."
  }
}

variable "oidc_groups_claim" {
  description = "The claim used for mapping groups in the OIDC identity provider"
  type        = string
  default     = "groups"
}

variable "oidc_groups_prefix" {
  description = "The prefix for groups in the OIDC identity provider"
  type        = string
  default     = "oidc"
}

variable "oidc_config_name" {
  description = "The name of the OIDC identity provider config"
  type        = string
}

variable "oidc_issuer_url" {
  description = "The issuer URL for the OIDC identity provider"
  type        = string

  validation {
    condition     = can(regex("^https://.*$", var.oidc_issuer_url))
    error_message = "The OIDC issuer URL must start with 'https://'."
  }
}

variable "oidc_required_claims" {
  description = "List of required claims for the OIDC identity provider"
  type        = list(string)
  default     = ["sub", "email"]

  validation {
    condition     = alltrue([for claim in var.oidc_required_claims : claim != ""])
    error_message = "Each claim must be a non-empty string."
  }
}

variable "oidc_username_claim" {
  description = "The claim used for mapping usernames in the OIDC identity provider"
  type        = string
  default     = "preferred_username"
}

variable "oidc_username_prefix" {
  description = "The prefix for usernames in the OIDC identity provider"
  type        = string
  default     = "oidc"
}

variable "oidc_tags" {
  description = "Tags to associate with the OIDC identity provider"
  type        = map(string)
  default     = {}
}

#######################
# EKS Access Entry AND Policy Association
#######################

variable "kubernetes_groups" {
  description = "List of Kubernetes groups for the EKS access entry"
  type        = list(string)

  validation {
    condition     = length(var.kubernetes_groups) > 0
    error_message = "At least one Kubernetes group must be specified."
  }
}

variable "principal_arn" {
  description = "The ARN of the principal for the EKS access entry"
  type        = string

  validation {
    condition     = length(var.principal_arn) > 0
    error_message = "The principal ARN cannot be empty."
  }
}

variable "access_entry_type" {
  description = "The type of the access entry (e.g., user, group)"
  type        = string
  default     = "user"

  validation {
    condition     = contains(["user", "group"], var.access_entry_type)
    error_message = "The access entry type must be either 'user' or 'group'."
  }
}

variable "user_name" {
  description = "The name of the user for the EKS access entry"
  type        = string

  validation {
    condition     = length(var.user_name) > 0
    error_message = "The user name cannot be empty."
  }
}

variable "access_entry_tags" {
  description = "Tags for the EKS access entry"
  type        = map(string)
  default     = {}
}

variable "access_policy_namespaces" {
  description = "Namespaces for the access policy"
  type        = list(string)
}

variable "access_policy_type" {
  description = "The type of access policy"
  type        = string
}

variable "access_policy_arn" {
  description = "The ARN of the access policy"
  type        = string
}

variable "access_policy_principal_arn" {
  description = "The ARN of the principal for the access policy"
  type        = string
}
