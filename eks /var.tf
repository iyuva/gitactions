

variable "cluster_names" {
  description = "List of EKS cluster names"
  type        = list(string)
#   default     = ["cluster1"]  # Default cluster name
}

variable "cluster_version" {
  description = "The version of the EKS clusters"
  type        = string
#   default     = "1.21"  # Default EKS version
}

variable "cluster_enabled_log_types" {
  description = "The enabled log types for the EKS clusters"
  type        = list(string)
#   default     = ["api", "audit"]  # Default enabled log types
}

variable "bootstrap_self_managed_addons" {
  description = "Whether to bootstrap self-managed addons for the clusters"
  type        = bool
  default     = true  # Default value for bootstrap self-managed addons
}

variable "authentication_mode" {
  description = "The authentication mode for the EKS clusters"
  type        = string
  default     = "AWS_IAM"  # Default authentication mode
}

variable "vpc_ids" {
  description = "List of VPC IDs for the clusters"
  type        = list(string)
#   default     = ["vpc-12345678"]  # Default VPC ID
}

variable "subnet_ids" {
  description = "List of subnet IDs for the clusters"
  type        = list(string)
#   default     = ["subnet-abc123", "subnet-def456"]  # Default subnet IDs
}

variable "cluster_endpoint_private_access" {
  description = "Whether private endpoint access is enabled for the EKS clusters"
  type        = bool
  default     = true  # Default for private access
}

variable "cluster_endpoint_public_access" {
  description = "Whether public endpoint access is enabled for the EKS clusters"
  type        = bool
  default     = true  # Default for public access
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs for public access to the EKS cluster endpoint"
  type        = list(string)
#   default     = ["0.0.0.0/0"]  # Default public access CIDR
}

variable "create_outposts_local_cluster" {
  description = "Flag to specify whether to create an outposts local cluster"
  type        = bool
  default     = false  # Default value for outposts local cluster
}

variable "cluster_ip_family" {
  description = "IP family for the EKS cluster"
  type        = string
  default     = "IPv4"  # Default IP family
}

variable "cluster_service_ipv4_cidr" {
  description = "IPv4 CIDR block for EKS cluster service"
  type        = string
#   default     = "172.20.0.0/16"  # Default IPv4 CIDR
}

variable "cluster_service_ipv6_cidr" {
  description = "IPv6 CIDR block for EKS cluster service"
  type        = string
#   default     = "fd00::/56"  # Default IPv6 CIDR
}

variable "outpost_instance_type" {
  description = "Control plane instance type for outposts"
  type        = string
#   default     = "m5.large"  # Default control plane instance type
}

variable "outpost_arns" {
  description = "List of outpost ARNs for the cluster"
  type        = list(string)
  default     = ["arn:aws:outposts:region:account-id:outpost/outpost-id"]  # Default outpost ARNs
}

variable "cluster_encryption_config" {
  description = "List of encryption configurations for the clusters"
  type        = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = [
    {
      provider_key_arn = "arn:aws:kms:region:account-id:key/key-id"
      resources        = ["secrets"]
    }
  ]
}

variable "cluster_upgrade_policy" {
  description = "List of upgrade policies for the clusters"
  type        = list(object({
    support_type = string
  }))
  default     = [{ support_type = "EKS" }]  # Default upgrade policy
}

variable "cluster_zonal_shift_config" {
  description = "Zonal shift configuration for the clusters"
  type        = list(object({
    enabled = bool
  }))
  default     = [{ enabled = false }]  # Default zonal shift config
}

variable "tags" {
  description = "Tags to be applied to the clusters"
  type        = map(string)
  default     = {
    "Environment" = "dev"
  }
}

variable "cluster_tags" {
  description = "Additional tags specific to the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_timeouts" {
  description = "Timeout settings for the cluster creation, update, and deletion"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "30m"
    update = "20m"
    delete = "30m"
  }
}




################ cloud watch  #####


variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "A map of tags specific to the EKS cluster."
  type        = map(string)
  default     = {}
}

variable "create_cluster_primary_security_group_tags" {
  description = "Flag to control if the primary security group tags should be created."
  type        = bool
  default     = true
}

variable "create_cloudwatch_log_group" {
  description = "Flag to control if CloudWatch log group should be created."
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Retention in days for the CloudWatch log group."
  type        = number
  default     = 30
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "The KMS key ID for encrypting CloudWatch log group."
  type        = string
  default     = ""
}

variable "cloudwatch_log_group_class" {
  description = "The class of the CloudWatch log group."
  type        = string
  default     = "Standard"
}

variable "create" {
  description = "Flag to control if the resources should be created."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster is located."
  type        = string
}

# variable "cluster_name" {
#   description = "Name of the EKS cluster."
#   type        = string
# }


############ access entry 

# Define outputs to display relevant resource details

output "eks_access_entries" {
  description = "The list of access entries created for the EKS cluster."
  value       = aws_eks_access_entry.this
}

output "eks_access_policy_associations" {
  description = "The list of policy associations created for the EKS cluster."
  value       = aws_eks_access_policy_association.this
}

##############cluster security grp 

# Define the variables required for the security group and security group rule resources

variable "create" {
  description = "Flag to control whether resources should be created."
  type        = bool
  default     = true
}

variable "create_cluster_security_group" {
  description = "Flag to control whether the EKS cluster security group should be created."
  type        = bool
  default     = true
}

variable "cluster_security_group_name" {
  description = "The name of the EKS cluster security group."
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_security_group_use_name_prefix" {
  description = "Flag to use a name prefix for the security group."
  type        = bool
  default     = false
}

variable "prefix_separator" {
  description = "Separator to use when creating a name prefix for the security group."
  type        = string
  default     = "-"
}

variable "cluster_security_group_description" {
  description = "Description of the EKS cluster security group."
  type        = string
  default     = "Security group for EKS cluster."
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created."
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resources."
  type        = map(string)
  default     = {}
}

variable "cluster_security_group_tags" {
  description = "Additional tags for the cluster security group."
  type        = map(string)
  default     = {}
}

variable "cluster_security_group_additional_rules" {
  description = "Additional security group rules to be added."
  type        = map(object({
    description          = string
    protocol             = string
    from_port            = number
    to_port              = number
    type                 = string
    cidr_blocks         = list(string)
    ipv6_cidr_blocks    = list(string)
    prefix_list_ids     = list(string)
    self                 = bool
    source_security_group_id = string
  }))
  default = {}
}

variable "node_security_group_id" {
  description = "The ID of the node security group."
  type        = string
  default     = ""
}




############## IRSA 

# Define the necessary variables for OpenID Connect provider and certificate resources

variable "create" {
  description = "Flag to control whether resources should be created."
  type        = bool
  default     = true
}

variable "enable_irsa" {
  description = "Flag to enable IRSA (IAM Roles for Service Accounts)."
  type        = bool
  default     = true
}

variable "create_outposts_local_cluster" {
  description = "Flag to control whether the cluster is an outpost."
  type        = bool
  default     = false
}

variable "include_oidc_root_ca_thumbprint" {
  description = "Flag to include the OIDC root CA thumbprint."
  type        = bool
  default     = true
}

variable "custom_oidc_thumbprints" {
  description = "Custom OIDC thumbprints if needed."
  type        = list(string)
  default     = []
}

variable "openid_connect_audiences" {
  description = "Audiences for the OIDC provider."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to be applied to the resources."
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}




#######################   IAM 

# Define variables for the IAM role creation and policy attachment

variable "clusters" {
  description = "A map of clusters with their configuration."
  type        = map(object({
    cluster_name                      = string
    create_outposts_local_cluster     = bool
    enable_cluster_encryption_config  = bool
    cluster_encryption_config        = object({
      provider_key_arn = string
    })
  }))
  default = {}
}

variable "create_iam_role" {
  description = "Flag to control whether IAM roles should be created."
  type        = bool
  default     = true
}

variable "iam_role_use_name_prefix" {
  description = "Flag to control if IAM role uses name prefix."
  type        = bool
  default     = false
}

variable "iam_role_path" {
  description = "The path for the IAM roles."
  type        = string
  default     = "/"
}

variable "iam_role_description" {
  description = "Description of the IAM role."
  type        = string
  default     = "IAM role for EKS cluster"
}

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary for the IAM role."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to be applied to the resources."
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "Tags to be applied to the IAM role."
  type        = map(string)
  default     = {}
}

variable "iam_role_policy_prefix" {
  description = "Prefix for IAM role policies."
  type        = string
  default     = "aws-eks-"
}

variable "iam_role_additional_policies" {
  description = "Additional IAM policies to be attached to the IAM role."
  type        = map(string)
  default     = {}
}

variable "attach_cluster_encryption_policy" {
  description = "Flag to control if the cluster encryption policy should be attached."
  type        = bool
  default     = true
}

variable "cluster_encryption_policy_use_name_prefix" {
  description = "Flag to use name prefix for cluster encryption policy."
  type        = bool
  default     = false
}

variable "cluster_encryption_policy_description" {
  description = "Description for the cluster encryption policy."
  type        = string
  default     = "Cluster encryption policy"
}

variable "cluster_encryption_policy_path" {
  description = "Path for the cluster encryption policy."
  type        = string
  default     = "/"
}

variable "create_kms_key" {
  description = "Flag to create KMS key for encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption if not creating the KMS key."
  type        = string
  default     = ""
}

variable "enable_cluster_encryption_config" {
  description = "Flag to enable cluster encryption configuration."
  type        = bool
  default     = true
}




###################### EKS Addons 


variable "cluster_addons" {
  description = "A map of EKS addons with their configuration."
  type = map(object({
    name                          = string
    addon_version                 = string
    most_recent                   = bool
    configuration_values         = map(string)
    pod_identity_association     = list(object({
      role_arn        = string
      service_account = string
    }))
    preserve                     = bool
    before_compute               = bool
    resolve_conflicts_on_create  = string
    resolve_conflicts_on_update  = string
    service_account_role_arn     = string
    timeouts                     = object({
      create = string
      update = string
      delete = string
    })
    tags                          = map(string)
  }))
  default = {}
}

variable "create" {
  description = "Flag to control resource creation."
  type        = bool
  default     = true
}

variable "create_outposts_local_cluster" {
  description = "Flag to control the creation of outposts local cluster."
  type        = bool
  default     = false
}

variable "cluster_version" {
  description = "The version of the EKS cluster."
  type        = string
  default     = "1.21"
}

variable "tags" {
  description = "Tags to be applied to the resources."
  type        = map(string)
  default     = {}
}

variable "cluster_addons_timeouts" {
  description = "Timeouts for the addon creation, update, and deletion."
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "30m"
    update = "30m"
    delete = "15m"
  }
}

variable "bootstrap_self_managed_addons" {
  description = "Flag to control if self-managed add-ons should be bootstrapped."
  type        = bool
  default     = false
}


########################## eks identifiers provider  

# variable "cluster_identity_providers" {
#   description = "A map of EKS identity provider configurations."
#   type = map(object({
#     client_id                     = string
#     identity_provider_config_name = string
#     issuer_url                    = string
#     groups_claim                  = string
#     groups_prefix                 = string
#     required_claims               = map(string)
#     username_claim                = string
#     username_prefix               = string
#     tags                          = map(string)
#   }))
#   default = {}
# }

# variable "create" {
#   description = "Flag to control resource creation."
#   type        = bool
#   default     = true
# }

# variable "create_outposts_local_cluster" {
#   description = "Flag to control the creation of outposts local cluster."
#   type        = bool
#   default     = false
# }

# variable "cluster_version" {
#   description = "The version of the EKS cluster."
#   type        = string
#   default     = "1.30"
# }

# variable "tags" {
#   description = "Tags to be applied to the resources."
#   type        = map(string)
#   default     = {}
# }




############






