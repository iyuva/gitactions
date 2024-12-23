# # variable "eks_clusters" {
# #   description = "A map of EKS cluster configurations where each key represents an EKS cluster and each value contains the configuration for that cluster."

# #   type = map(object({
# #     # Cluster Name
# #     cluster_name = string
# #     description  = "The name of the EKS cluster. The name must be unique within the AWS region."
# #     default      = "my-eks-cluster"
# #     # validation = {
# #     #   condition     = length(var.eks_clusters) > 0
# #     #   error_message = "At least one EKS cluster configuration must be provided."
# #     # }

# #     # Kubernetes Version
# #     cluster_version = string
# #     description     = "The Kubernetes version of the cluster. EKS supports versions such as '1.21', '1.22', etc."
# #     default         = "1.31"
# #     # validation = {
# #     #   condition     = can(regex("^\\d+\\.\\d+$", var.eks_clusters[cluster.key].cluster_version))
# #     #   error_message = "Cluster version must follow the format 'X.Y', where X and Y are numbers (e.g., 1.30, 1.31)."
# #     # }

# #     # Enabled Log Types
# #     cluster_enabled_log_types = list(string)
# #     description               = "A list of enabled log types for the EKS cluster (e.g., 'api', 'audit', 'authenticator')."
# #     default                   = ["api", "audit", "authenticator"]
# #     # validation = {
# #     #   condition     = length(var.eks_clusters[cluster.key].cluster_enabled_log_types) > 0
# #     #   error_message = "At least one log type must be enabled for the cluster."
# #     # }

# #     # Bootstrap Self-Managed Addons
# #     bootstrap_self_managed_addons = bool
# #     description                   = "Whether or not to bootstrap self-managed addons for the EKS cluster."
# #     default                       = false
# #     # validation = {
# #     #   condition     = var.eks_clusters[cluster.key].bootstrap_self_managed_addons == false
# #     #   error_message = "Bootstrap self-managed addons must be set to false."
# #     # }

# #     # Authentication Mode
# #     authentication_mode = string
# #     description         = "The authentication mode for the EKS cluster. Must be one of 'CONFIG_MAP', 'API', or 'API_AND_CONFIG_MAP'."
# #     default             = "API"
# #     # validation = {
# #     #   condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.eks_clusters[cluster.key].authentication_mode)
# #     #   error_message = "Authentication mode must be one of 'CONFIG_MAP', 'API', or 'API_AND_CONFIG_MAP'."
# #     # }

# #     # Bootstrap Cluster Creator Admin Permissions
# #     bootstrap_cluster_creator_admin_permissions = bool
# #     description                                 = "Whether to give the cluster creator admin permissions during the bootstrap process."
# #     default                                     = false

# #     # Private Endpoint Access
# #     cluster_endpoint_private_access = bool
# #     description                     = "Whether the EKS API server should be accessible through a private endpoint."
# #     default                         = true

# #     # Public Endpoint Access
# #     cluster_endpoint_public_access = bool
# #     description                    = "Whether the EKS API server should be accessible through a public endpoint."
# #     default                        = false
# #     # validation = {
# #     #   condition     = !var.eks_clusters[cluster.key].cluster_endpoint_public_access || length(var.eks_clusters[cluster.key].cluster_endpoint_public_access_cidrs) > 0
# #     #   error_message = "Public access is false, CIDR block list should be empty."
# #     # }

# #     # Public Endpoint Access CIDRs
# #     cluster_endpoint_public_access_cidrs = list(string)
# #     description                          = "A list of CIDR blocks that are allowed to access the public endpoint."
# #     default                              = []

# #     # Subnet IDs
# #     subnet_ids  = list(string)
# #     description = "A list of subnet IDs to associate with the EKS cluster."
# #     default     = []
# #     # validation = {
# #     #   condition     = length(var.eks_clusters[cluster.key].subnet_ids) > 0
# #     #   error_message = "At least one subnet ID must be provided for each EKS cluster."
# #     # }

# #     # Cluster IP Family
# #     cluster_ip_family = string
# #     description       = "The IP family to use for the cluster. Can be 'ipv4' or 'ipv6'."
# #     default           = "ipv4"
# #     # validation = {
# #     #   condition     = contains(["ipv4", "ipv6"], var.eks_clusters[cluster.key].cluster_ip_family)
# #     #   error_message = "Cluster IP family must be either 'ipv4' or 'ipv6'."
# #     # }

# #     # Cluster Service IPv4 CIDR
# #     cluster_service_ipv4_cidr = string
# #     description               = "The CIDR block for the IPv4 service network for the EKS cluster."
# #     default                   = ""
# #     # validation = {
# #     #   condition     = var.eks_clusters[cluster.key].cluster_service_ipv4_cidr == "" || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.eks_clusters[cluster.key].cluster_service_ipv4_cidr))
# #     #   error_message = "If provided, IPv4 CIDR must be a valid CIDR block."
# #     # }

# #     # Cluster Service IPv6 CIDR
# #     cluster_service_ipv6_cidr = string
# #     description               = "The CIDR block for the IPv6 service network for the EKS cluster."
# #     default                   = ""
# #     # validation = {
# #     #   condition     = var.eks_clusters[cluster.key].cluster_service_ipv6_cidr == "" || can(regex("^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}/[0-9]{1,3}$", var.eks_clusters[cluster.key].cluster_service_ipv6_cidr))
# #     #   error_message = "If provided, IPv6 CIDR must be a valid CIDR block."
# #     # }

# #     # KMS Key ARN for Encryption
# #     kms_key_arn = string
# #     description = "The ARN of the KMS key to use for encrypting the EKS cluster secrets."
# #     default     = ""

# #     # Upgrade Policy Support Type
# #     upgrade_policy_support_type = string
# #     description                 = "The upgrade policy for the EKS cluster. Can be 'STANDARD' or 'EXTENDED'."
# #     default                     = "EXTENDED"
# #     # validation = {
# #     #   condition     = contains(["STANDARD", "EXTENDED"], var.eks_clusters[cluster.key].upgrade_policy_support_type)
# #     #   error_message = "Upgrade policy support type must be 'STANDARD' or 'EXTENDED'."
# #     # }

# #     # Zonal Shift Configuration
# #     zonal_shift_config_enabled = bool
# #     description                = "Whether to enable zonal shift configuration for the EKS cluster."
# #     default                    = false

# #     # Tags for the Cluster
# #     tags        = map(string)
# #     description = "A map of key-value pairs for tags to assign to the EKS cluster."
# #     default = {
# #       "Environment" = "dev"
# #       "Team"        = "team-a"
# #     }

# #     # Timeouts for Cluster Management
# #     cluster_timeouts_create = string
# #     description             = "The timeout duration for creating the EKS cluster (e.g., '10m')."
# #     default                 = "30m"

# #     cluster_timeouts_update = string
# #     description             = "The timeout duration for updating the EKS cluster (e.g., '10m')."
# #     default                 = "30m"

# #     cluster_timeouts_delete = string
# #     description             = "The timeout duration for deleting the EKS cluster (e.g., '10m')."
# #     default                 = "30m"
# #   }))

# #   # General Validation (Map length should be > 0)
# #   #   validation {
# #   #     condition     = length(var.eks_clusters) > 0
# #   #     error_message = "At least one EKS cluster configuration must be provided."
# #   #   }
# # }




# # #### Security group 
# # variable "vpc_id" {
# #   description = "The ID of the VPC"
# #   type        = string
# # }


# ####IAM 

# # variable "iam_policy_version" {
# #   description = "The version of the IAM policy"
# #   type        = string
# #   default     = "2012-10-17"
# # }


# ##region

# # variable "aws_region" {
# #   description = "The AWS region to deploy resources"
# #   type        = string
# #   default     = "us-east-1"
# # }



# # Variables for cluster and VPC details
# variable "eks_clusters" {
#   description = "A map of EKS clusters to be created."
#   type = map(object({
#     cluster_name                                = string
#     cluster_version                             = string
#     cluster_enabled_log_types                   = list(string)
#     bootstrap_self_managed_addons               = list(string)
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
#     cluster_timeouts_create                     = optional(string, null)
#     cluster_timeouts_update                     = optional(string, null)
#     cluster_timeouts_delete                     = optional(string, null)
#   }))
# }

# # variable "vpc_id" {
# #   description = "The VPC ID in which the EKS cluster will be created."
# #   type        = string
# # }

# # variable "iam_policy_version" {
# #   description = "The IAM policy version for assume role."
# #   type        = string
# #   default     = "2012-10-17"
# # }

# variable "vpc_id" {
#   description = "The ID of the VPC"
#   type        = string
# }

# variable "iam_policy_version" {
#   description = "The version of the IAM policy"
#   type        = string
#   default     = "2012-10-17"
# }

# variable "aws_region" {
#   description = "The AWS region to deploy resources"
#   type        = string
#   default     = "us-east-1"
# }






###############
## NEW
############
# # # Variables for the VPC and clusters
# # variable "vpc_id" {
# #   description = "The ID of the VPC to deploy the resources into"
# #   type        = string
# #   default     = "vpc-04eecbca3288149bf"
# # }

# # variable "eks_clusters" {
# #   description = "Map of EKS cluster configurations"
# #   type = map(object({
# #     cluster_name                                = string
# #     cluster_version                             = string
# #     cluster_enabled_log_types                   = list(string)
# #     bootstrap_self_managed_addons               = bool
# #     authentication_mode                         = string
# #     bootstrap_cluster_creator_admin_permissions = bool
# #     cluster_endpoint_private_access             = bool
# #     cluster_endpoint_public_access              = bool
# #     cluster_endpoint_public_access_cidrs        = list(string)
# #     subnet_ids                                  = list(string)
# #     cluster_ip_family                           = string
# #     cluster_service_ipv4_cidr                   = string
# #     #cluster_service_ipv6_cidr                   = string
# #     upgrade_policy_support_type = string
# #     zonal_shift_config_enabled  = bool
# #     tags                        = map(string)
# #     cluster_timeouts_create     = string
# #     cluster_timeouts_update     = string
# #     cluster_timeouts_delete     = string
# #   }))
# #   default = {
# #     "default-cluster" = {
# #       cluster_name                                = "default-cluster"
# #       cluster_version                             = "1.23"
# #       cluster_enabled_log_types                   = ["api", "audit", "authenticator"]
# #       bootstrap_self_managed_addons               = true
# #       authentication_mode                         = "API"
# #       bootstrap_cluster_creator_admin_permissions = true
# #       cluster_endpoint_private_access             = true
# #       cluster_endpoint_public_access              = true
# #       cluster_endpoint_public_access_cidrs        = ["0.0.0.0/0"]
# #       subnet_ids                                  = ["subnet-0cc8cd474a4b07f12", "subnet-045ceca067469d5cd"]
# #       cluster_ip_family                           = "ipv4"
# #       cluster_service_ipv4_cidr                   = "10.100.0.0/16"
# #       #cluster_service_ipv6_cidr                   = "fd00:abcd::/56"
# #       upgrade_policy_support_type = "STANDARD"
# #       zonal_shift_config_enabled  = false
# #       tags = {
# #         "Environment" = "Production",
# #         "Team"        = "DevOps"
# #       }
# #       cluster_timeouts_create = "30m"
# #       cluster_timeouts_update = "15m"
# #       cluster_timeouts_delete = "20m"
# #     }
# #   }
# # }

# # variable "iam_policy_version" {
# #   description = "The IAM policy version to use for assume role policy"
# #   type        = string
# #   default     = "2012-10-17"
# # }


# # variable "aws_region" {
# #   description = "The AWS region to deploy resources"
# #   type        = string
# #   default     = "us-east-1"
# # }




# # variables.tf

# # Cluster Name
# variable "cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
#   default     = ""

#   validation {
#     condition     = length(var.cluster_name) > 0
#     error_message = "Cluster name must not be empty."
#   }
# }

# # Cluster Version
# variable "cluster_version" {
#   description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
#   type        = string
#   default     = null

#   validation {
#     condition     = can(regex("^\\d+\\.\\d+$", var.cluster_version))
#     error_message = "Cluster version must be in the format `<major>.<minor>` (e.g., `1.27`)."
#   }
# }

# # VPC ID
# variable "vpc_id" {
#   description = "The ID of the VPC where the resources will be deployed."
#   type        = string

#   validation {
#     condition     = length(var.vpc_id) > 0
#     error_message = "VPC ID must not be empty."
#   }
# }

# # Subnet IDs for EKS Cluster
# variable "subnet_ids" {
#   description = "List of subnet IDs for EKS cluster networking."
#   type        = list(string)
#   default     = []

#   validation {
#     condition     = length(var.subnet_ids) > 0
#     error_message = "At least one subnet ID must be provided."
#   }
# }

# # AWS Managed Policies
# variable "aws_managed_policies" {
#   description = "List of AWS Managed IAM Policies to attach to the EKS role."
#   type        = list(string)
#   default = [
#     "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
#     "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
#     "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
#     "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
#     "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
#     "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
#   ]

#   validation {
#     condition     = length(var.aws_managed_policies) > 0
#     error_message = "At least one AWS managed policy must be provided."
#   }
# }

# # Customer Managed Policies
# variable "customer_managed_policies" {
#   description = "List of customer managed policies with names, descriptions, and the policy document."
#   type = list(object({
#     name        = string
#     description = string
#     policy      = string
#   }))
#   default = []

#   validation {
#     condition     = length(var.customer_managed_policies) == 0 || alltrue([for policy in var.customer_managed_policies : length(policy.name) > 0 && length(policy.policy) > 0])
#     error_message = "Each customer managed policy must have a valid name and policy document."
#   }
# }

# # # Security Group Rules for EKS Cluster
# # variable "security_group_rules" {
# #   description = "List of custom security group rules to apply to the EKS cluster."
# #   type = object({
# #     ingress = list(object({
# #       from_port   = number
# #       to_port     = number
# #       protocol    = string
# #       cidr_blocks = list(string)
# #     }))
# #     egress = list(object({
# #       from_port   = number
# #       to_port     = number
# #       protocol    = string
# #       cidr_blocks = list(string)
# #     }))
# #   })
# #   default = {
# #     ingress = [
# #       { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [] },
# #       { from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = [] }
# #     ]
# #     egress = [
# #       { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [] }
# #     ]
# #   }

# #   validation {
# #     condition     = length(var.security_group_rules.ingress) > 0 && length(var.security_group_rules.egress) > 0
# #     error_message = "Security group rules must include both ingress and egress rules."
# #   }
# # }

# # Cluster Timeouts for EKS operations
# variable "cluster_timeouts" {
#   description = "Timeouts for EKS Cluster operations (create, update, delete)."
#   type = object({
#     create = string
#     update = string
#     delete = string
#   })
#   default = {
#     create = "30m"
#     update = "30m"
#     delete = "30m"
#   }

#   validation {
#     condition = (can(regex("^[0-9]+[smhd]$", var.cluster_timeouts.create)) &&
#       can(regex("^[0-9]+[smhd]$", var.cluster_timeouts.update)) &&
#     can(regex("^[0-9]+[smhd]$", var.cluster_timeouts.delete)))
#     error_message = "Timeouts must be specified as a positive number with a valid time unit (e.g., `30m`, `1h`)."
#   }
# }

# # # EKS Cluster Configuration (vpc_id, cluster_name, etc.)
# # variable "eks_clusters" {
# #   description = "A map of EKS clusters configurations."
# #   type = map(object({
# #     cluster_name                                = string
# #     cluster_version                             = string
# #     cluster_enabled_log_types                   = list(string)
# #     bootstrap_self_managed_addons               = bool
# #     authentication_mode                         = string
# #     bootstrap_cluster_creator_admin_permissions = bool
# #     cluster_endpoint_private_access             = bool
# #     cluster_endpoint_public_access              = bool
# #     cluster_endpoint_public_access_cidrs        = list(string)
# #     subnet_ids                                  = list(string)
# #     cluster_ip_family                           = string
# #     cluster_service_ipv4_cidr                   = string
# #     cluster_service_ipv6_cidr                   = string
# #     upgrade_policy_support_type                 = string
# #     zonal_shift_config_enabled                  = bool
# #     tags                                        = map(string)
# #     cluster_timeouts_create                     = string
# #     cluster_timeouts_update                     = string
# #     cluster_timeouts_delete                     = string
# #   }))
# #   default = {}

# #   validation {
# #     condition     = length(var.eks_clusters) > 0
# #     error_message = "At least one EKS cluster configuration must be provided."
# #   }
# # }

# # # Security Group rules for EKS Cluster
# # variable "eks_security_group_rules" {
# #   description = "Security group rules to be applied to the EKS cluster."
# #   type = object({
# #     ingress = list(object({
# #       from_port   = number
# #       to_port     = number
# #       protocol    = string
# #       cidr_blocks = list(string)
# #     }))
# #     egress = list(object({
# #       from_port   = number
# #       to_port     = number
# #       protocol    = string
# #       cidr_blocks = list(string)
# #     }))
# #   })
# #   default = {
# #     ingress = [
# #       { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [] },
# #       { from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = [] }
# #     ]
# #     egress = [
# #       { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [] }
# #     ]
# #   }

# #   validation {
# #     condition     = length(var.eks_security_group_rules.ingress) > 0 && length(var.eks_security_group_rules.egress) > 0
# #     error_message = "Security group rules must include both ingress and egress rules."
# #   }
# # }



# # Variables for the VPC and clusters

# # Cluster Name
# variable "cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
#   default     = ""

#   validation {
#     condition     = length(var.cluster_name) > 0
#     error_message = "Cluster name must not be empty."
#   }
# }

# # Cluster Version
# variable "cluster_version" {
#   description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
#   type        = string
#   default     = null

#   validation {
#     condition     = can(regex("^\\d+\\.\\d+$", var.cluster_version))
#     error_message = "Cluster version must be in the format `<major>.<minor>` (e.g., `1.27`)."
#   }
# }

# # VPC ID
# variable "vpc_id" {
#   description = "The ID of the VPC where the resources will be deployed."
#   type        = string

#   validation {
#     condition     = length(var.vpc_id) > 0
#     error_message = "VPC ID must not be empty."
#   }
# }

# # Subnet IDs for EKS Cluster
# variable "subnet_ids" {
#   description = "List of subnet IDs for EKS cluster networking."
#   type        = list(string)
#   default     = []

#   validation {
#     condition     = length(var.subnet_ids) > 0
#     error_message = "At least one subnet ID must be provided."
#   }
# }

# # AWS Managed Policies
# variable "aws_managed_policies" {
#   description = "List of AWS Managed IAM Policies to attach to the EKS role."
#   type        = list(string)
#   default = [
#     "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
#     "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
#     "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
#     "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
#     "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
#     "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
#   ]

#   validation {
#     condition     = length(var.aws_managed_policies) > 0
#     error_message = "At least one AWS managed policy must be provided."
#   }
# }

# # Customer Managed Policies
# variable "customer_managed_policies" {
#   description = "List of customer managed policies with names, descriptions, and the policy document."
#   type = list(object({
#     name        = string
#     description = string
#     policy      = string
#   }))
#   default = []

#   validation {
#     condition     = length(var.customer_managed_policies) == 0 || alltrue([for policy in var.customer_managed_policies : length(policy.name) > 0 && length(policy.policy) > 0])
#     error_message = "Each customer managed policy must have a valid name and policy document."
#   }
# }

# # Cluster Timeouts for EKS operations
# variable "cluster_timeouts" {
#   description = "Timeouts for EKS Cluster operations (create, update, delete)."
#   type = object({
#     create = string
#     update = string
#     delete = string
#   })
#   default = {
#     create = "30m"
#     update = "30m"
#     delete = "30m"
#   }

#   validation {
#     condition = (can(regex("^[0-9]+[smhd]$", var.cluster_timeouts.create)) &&
#       can(regex("^[0-9]+[smhd]$", var.cluster_timeouts.update)) &&
#     can(regex("^[0-9]+[smhd]$", var.cluster_timeouts.delete)))
#     error_message = "Timeouts must be specified as a positive number with a valid time unit (e.g., `30m`, `1h`)."
#   }
# }

# # AWS Region
# variable "aws_region" {
#   description = "The AWS region to deploy resources"
#   type        = string
#   default     = "us-east-1"
# }

# # Output the Security Group ID
# output "eks_security_group_id" {
#   value = aws_security_group.eks_sg_dynamic.id
# }




##########
#NEW
##########

# variable "vpc_id" {
#   description = "ID of the VPC where the EKS cluster will be deployed"
#   type        = string
#   default     = ""

#   validation {
#     condition     = length(var.vpc_id) > 0
#     error_message = "VPC ID cannot be empty."
#   }
# }

# variable "cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
#   default     = ""

#   validation {
#     condition     = length(var.cluster_name) > 0
#     error_message = "Cluster name cannot be empty."
#   }
# }

# variable "cluster_version" {
#   description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
#   type        = string
#   default     = null

#   validation {
#     condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
#     error_message = "Cluster version must follow the format <major>.<minor>, for example '1.27'."
#   }
# }

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

# variable "vpc_id" {
#   description = "The ID of the VPC to deploy resources into."
#   type        = string

#   validation {
#     condition     = length(var.vpc_id) > 0
#     error_message = "VPC ID cannot be empty."
#   }
# }

# variable "aws_managed_policies" {
#   description = "List of AWS managed policies to be attached to the IAM role"
#   type        = list(string)

#   validation {
#     condition     = length(var.aws_managed_policies) > 0
#     error_message = "At least one AWS managed policy should be specified."
#   }
# }

# variable "customer_managed_policies" {
#   description = "List of custom IAM policies to be created for the EKS setup"
#   type = list(object({
#     name        = string
#     description = string
#     policy      = string
#   }))
#   default = []

#   validation {
#     condition     = length(var.customer_managed_policies) > 0
#     error_message = "At least one customer managed policy should be specified."
#   }
# }

# variable "cluster_timeouts_create" {
#   description = "Timeout for creating the EKS cluster"
#   type        = string
#   default     = "30m"

#   validation {
#     condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_create))
#     error_message = "Cluster timeout for creation must be a valid duration (e.g., 30m, 1h)."
#   }
# }

# variable "cluster_timeouts_update" {
#   description = "Timeout for updating the EKS cluster"
#   type        = string
#   default     = "30m"

#   validation {
#     condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_update))
#     error_message = "Cluster timeout for update must be a valid duration (e.g., 30m, 1h)."
#   }
# }

# variable "cluster_timeouts_delete" {
#   description = "Timeout for deleting the EKS cluster"
#   type        = string
#   default     = "30m"

#   validation {
#     condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_delete))
#     error_message = "Cluster timeout for deletion must be a valid duration (e.g., 30m, 1h)."
#   }
# }

# variable "subnet_ids" {
#   description = "List of subnet IDs to attach to the EKS cluster"
#   type        = list(string)
#   default     = []

#   validation {
#     condition     = length(var.subnet_ids) > 0
#     error_message = "At least one subnet ID must be specified."
#   }
# }

# variable "cluster_enabled_log_types" {
#   description = "List of enabled log types for the EKS cluster"
#   type        = list(string)
#   default     = []

#   validation {
#     condition     = alltrue([for log_type in var.cluster_enabled_log_types : log_type in ["api", "audit", "authenticator", "controllerManager", "scheduler"]])
#     error_message = "Log types must be one of: api, audit, authenticator, controllerManager, scheduler."
#   }
# }
# variable "cluster_enabled_log_types" {
#   description = "List of enabled log types for the EKS cluster"
#   type        = list(string)
#   default     = []

#   validation {
#     condition     = alltrue([for log_type in var.cluster_enabled_log_types : contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)])
#     error_message = "Log types must be one of: api, audit, authenticator, controllerManager, scheduler."
#   }
# }



# variable "cluster_ip_family" {
#   description = "IP family for the EKS cluster"
#   type        = string
#   default     = "IPv4"

#   validation {
#     condition     = var.cluster_ip_family == "IPv4" || var.cluster_ip_family == "IPv6"
#     error_message = "Cluster IP family must be either 'IPv4' or 'IPv6'."
#   }
# }

# variable "cluster_service_ipv4_cidr" {
#   description = "IPv4 CIDR block for the EKS cluster's service network"
#   type        = string
#   default     = "10.100.0.0/16"

#   validation {
#     condition     = can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/(\\d{1,2})$", var.cluster_service_ipv4_cidr))
#     error_message = "Cluster service IPv4 CIDR must be a valid CIDR block, e.g., '10.100.0.0/16'."
#   }
# }

# variable "cluster_service_ipv6_cidr" {
#   description = "IPv6 CIDR block for the EKS cluster's service network"
#   type        = string
#   default     = null

#   validation {
#     condition     = can(regex("^\\[([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}]\\/(\\d{1,3})$", var.cluster_service_ipv6_cidr)) || var.cluster_service_ipv6_cidr == null
#     error_message = "Cluster service IPv6 CIDR must be a valid CIDR block, e.g., '[2001:db8::1]/64'."
#   }
# }

# variable "cluster_endpoint_private_access" {
#   description = "Whether private access to the EKS cluster endpoint is enabled"
#   type        = bool
#   default     = true
# }

# variable "cluster_endpoint_public_access" {
#   description = "Whether public access to the EKS cluster endpoint is enabled"
#   type        = bool
#   default     = false
# }

# variable "cluster_endpoint_public_access_cidrs" {
#   description = "List of CIDR blocks for allowed public access to the EKS cluster endpoint"
#   type        = list(string)
#   #default     = ["10.0.0.0/24"]

#   validation {
#     condition     = length(var.cluster_endpoint_public_access_cidrs) > 0
#     error_message = "At least one CIDR block must be specified for public access."
#   }
# }

# variable "cluster_timeouts_create" {
#   description = "Timeout for creating the EKS cluster"
#   type        = string
#   default     = "30m"

#   validation {
#     condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_create))
#     error_message = "Cluster timeout for creation must be a valid duration (e.g., 30m, 1h)."
#   }
# }

# variable "cluster_timeouts_update" {
#   description = "Timeout for updating the EKS cluster"
#   type        = string
#   default     = "30m"

#   validation {
#     condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_update))
#     error_message = "Cluster timeout for update must be a valid duration (e.g., 30m, 1h)."
#   }
# }

# variable "cluster_timeouts_delete" {
#   description = "Timeout for deleting the EKS cluster"
#   type        = string
#   default     = "30m"

#   validation {
#     condition     = can(regex("^\\d+[mhd]$", var.cluster_timeouts_delete))
#     error_message = "Cluster timeout for deletion must be a valid duration (e.g., 30m, 1h)."
#   }
# }


