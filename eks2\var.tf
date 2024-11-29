# Define variables for the various AWS EKS cluster attributes

# List of EKS cluster names
variable "eks_cluster_names" {
  description = "List of names of the created EKS clusters"
  type        = list(string)
  default     = []
}

# List of ARNs of the created EKS clusters
variable "eks_cluster_arns" {
  description = "List of ARNs of the created EKS clusters"
  type        = list(string)
  default     = []
}

# List of Kubernetes API server endpoints for each EKS cluster
variable "eks_cluster_endpoint" {
  description = "The Kubernetes API server endpoint for each EKS cluster"
  type        = list(string)
  default     = []
}

# List of IAM role ARNs used by the EKS clusters
variable "eks_cluster_role_arn" {
  description = "IAM role ARN used by the EKS clusters"
  type        = list(string)
  default     = []
}

# List of VPC IDs associated with each EKS cluster
variable "eks_cluster_vpc_id" {
  description = "VPC ID associated with each EKS cluster"
  type        = list(string)
  default     = []
}

# List of subnet IDs associated with each EKS cluster
variable "eks_cluster_subnet_ids" {
  description = "List of subnet IDs for each EKS cluster"
  type        = list(list(string))
  default     = []
}

# List of enabled log types for each EKS cluster
variable "eks_cluster_enabled_log_types" {
  description = "The enabled log types for each EKS cluster"
  type        = list(list(string))
  default     = []
}

# List of encryption configurations for each EKS cluster
variable "eks_cluster_encryption_config" {
  description = "The encryption configuration for each EKS cluster"
  type        = list(any)  # 'any' type to accommodate different encryption configurations
  default     = []
}

# Tags applied to each EKS cluster
variable "eks_cluster_tags" {
  description = "Tags applied to each EKS cluster"
  type        = list(map(string))
  default     = []
}

# Timeouts for EKS cluster creation, update, and deletion
variable "eks_cluster_timeouts" {
  description = "Timeouts for each EKS cluster creation, update, and deletion"
  type        = list(map(string))
  default     = []
}

################ CloudWatch Logs ################

# The name of the CloudWatch log group
variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group."
  type        = list(string)
  default     = []
}

################ Access Entries ################

# List of access entries for the EKS cluster
variable "eks_access_entries" {
  description = "The list of access entries created for the EKS cluster."
  type        = list(any)  # 'any' type to handle diverse access entry configurations
  default     = []
}

# List of policy associations for the EKS cluster
variable "eks_access_policy_associations" {
  description = "The list of policy associations created for the EKS cluster."
  type        = list(any)  # 'any' to handle different policy association configurations
  default     = []
}

################ Cluster Security Group ################

# The ID of the EKS cluster security group
variable "cluster_security_group_id" {
  description = "The ID of the EKS cluster security group."
  type        = string
  default     = ""
}

# Security group rules for the EKS cluster
variable "cluster_security_group_rules" {
  description = "The security group rules associated with the EKS cluster."
  type        = list(any)  # 'any' type to handle varied security group rule configurations
  default     = []
}

################ IRSA ################

# The URL of the OpenID Connect provider
variable "oidc_provider_url" {
  description = "The URL of the OpenID Connect provider."
  type        = string
  default     = ""
}

# The thumbprints used in the OpenID Connect provider
variable "oidc_provider_thumbprints" {
  description = "The thumbprints used in the OpenID Connect provider."
  type        = list(string)
  default     = []
}

################ IAM ################

# The names of the IAM roles created
variable "iam_role_names" {
  description = "The names of the IAM roles created."
  type        = map(string)
  default     = {}
}

# The ARNs of the cluster encryption policies
variable "cluster_encryption_policy_arns" {
  description = "The ARNs of the cluster encryption policies created."
  type        = map(string)
  default     = {}
}

################ EKS Addons ################

# The versions of the EKS addons
variable "eks_addon_versions" {
  description = "The versions of the EKS addons."
  type        = map(string)
  default     = {}
}

# The ARNs of the EKS addons
variable "eks_addon_arns" {
  description = "The ARNs of the EKS addons."
  type        = map(string)
  default     = {}
}

# The ARNs of the EKS addons with before_compute flag
variable "eks_addon_before_compute_arns" {
  description = "The ARNs of the EKS addons with before_compute flag."
  type        = map(string)
  default     = {}
}

################### EKS Identity Provider #################

# Variables for EKS identity provider configurations (commented out as they're not in use)
# variable "eks_identity_provider_config_names" {
#   description = "The names of the created identity provider configurations."
#   type        = map(string)
#   default     = {}
# }

# variable "eks_identity_provider_tags" {
#   description = "Tags for each identity provider configuration."
#   type        = map(string)
#   default     = {}
# }
