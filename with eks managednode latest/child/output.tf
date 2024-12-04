#######################
# IAM Resources Outputs
#######################

output "eks_role_name" {
  description = "The name of the EKS IAM Role"
  value       = var.eks_role_name
}

output "eks_policy_name" {
  description = "The name of the EKS IAM Policy"
  value       = var.eks_policy_name
}

output "eks_policy_description" {
  description = "The description of the EKS IAM Policy"
  value       = var.eks_policy_description
}

output "default_tags" {
  description = "Default tags applied to the resources"
  value       = var.default_tags
}

#######################
# EKS Cluster Outputs
#######################

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = var.cluster_name
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = var.cluster_version
}

output "enabled_log_types" {
  description = "The enabled log types for the EKS cluster"
  value       = var.enabled_log_types
}

output "bootstrap_addons" {
  description = "Indicates if self-managed bootstrap addons are enabled"
  value       = var.bootstrap_addons
}

output "authentication_mode" {
  description = "The authentication mode for the EKS cluster"
  value       = var.authentication_mode
}

output "cluster_creator_permissions" {
  description = "Indicates if cluster creator has admin permissions"
  value       = var.cluster_creator_permissions
}

output "subnet_ids" {
  description = "List of subnet IDs associated with the EKS cluster"
  value       = var.subnet_ids
}

output "endpoint_private_access" {
  description = "Indicates if the EKS API server endpoint is private"
  value       = var.endpoint_private_access
}

output "endpoint_public_access" {
  description = "Indicates if the EKS API server endpoint is public"
  value       = var.endpoint_public_access
}

output "public_access_cidrs" {
  description = "List of CIDR blocks for public access to the EKS API server"
  value       = var.public_access_cidrs
}

output "cluster_ip_family" {
  description = "The IP family for the EKS cluster (IPv4 or dualstack)"
  value       = var.cluster_ip_family
}

output "cluster_service_ipv4_cidr" {
  description = "The CIDR block for the cluster's service IP range"
  value       = var.cluster_service_ipv4_cidr
}

# output "cluster_upgrade_policy" {
#   description = "The upgrade policy for the EKS cluster"
#   value       = var.cluster_upgrade_policy
# }

output "cluster_zonal_shift_enabled" {
  description = "Indicates if zonal shift is enabled for the EKS cluster"
  value       = var.cluster_zonal_shift_enabled
}

output "cluster_timeouts" {
  description = "Timeout configuration for EKS cluster creation, update, and deletion"
  value       = var.cluster_timeouts
}

#######################
# Security Groups for EKS Cluster Outputs
#######################

output "eks_security_group_name" {
  description = "The name of the security group for EKS Control Plane"
  value       = var.eks_security_group_name
}

output "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  value       = var.vpc_id
}

output "security_group_protocol" {
  description = "The protocol for security group rules"
  value       = var.security_group_protocol
}

output "security_group_from_port" {
  description = "The starting port for security group rules"
  value       = var.security_group_from_port
}

output "security_group_to_port" {
  description = "The ending port for security group rules"
  value       = var.security_group_to_port
}

output "security_group_type" {
  description = "The type of security group rule"
  value       = var.security_group_type
}

output "security_group_description" {
  description = "Description for the security group rule"
  value       = var.security_group_description
}

output "security_group_cidr_blocks" {
  description = "List of CIDR blocks for security group ingress"
  value       = var.security_group_cidr_blocks
}

#######################
# EC2 Tags for EKS Resources Outputs
#######################

output "subnet_name" {
  description = "The name of the subnets"
  value       = var.subnet_name
}

#######################
# IAM Roles and Policies for Addons Outputs
#######################

# output "addon_names" {
#   description = "The names of the EKS addons"
#   value       = var.addon_names
# }

# output "addon_versions" {
#   description = "The versions of the EKS addons"
#   value       = var.addon_versions
# }

#######################
# OIDC Identity Provider Outputs
#######################

# output "oidc_client_id" {
#   description = "OIDC client ID for identity provider"
#   value       = var.oidc_client_id
# }

# output "oidc_groups_claim" {
#   description = "The claim used for mapping groups in the OIDC identity provider"
#   value       = var.oidc_groups_claim
# }

# output "oidc_groups_prefix" {
#   description = "The prefix for groups in the OIDC identity provider"
#   value       = var.oidc_groups_prefix
# }

# output "oidc_config_name" {
#   description = "The name of the OIDC identity provider config"
#   value       = var.oidc_config_name
# }

# output "oidc_issuer_url" {
#   description = "The issuer URL for the OIDC identity provider"
#   value       = var.oidc_issuer_url
# }

output "oidc_required_claims" {
  description = "List of required claims for the OIDC identity provider"
  value       = var.oidc_required_claims
}

output "oidc_username_claim" {
  description = "The claim used for mapping usernames in the OIDC identity provider"
  value       = var.oidc_username_claim
}

output "oidc_username_prefix" {
  description = "The prefix for usernames in the OIDC identity provider"
  value       = var.oidc_username_prefix
}

output "oidc_tags" {
  description = "Tags to associate with the OIDC identity provider"
  value       = var.oidc_tags
}

#######################
# EKS Access Entry AND Policy Association Outputs
#######################

# output "kubernetes_groups" {
#   description = "List of Kubernetes groups for the EKS access entry"
#   value       = var.kubernetes_groups
# }

# output "principal_arn" {
#   description = "The ARN of the principal for the EKS access entry"
#   value       = var.principal_arn
# }

# output "access_entry_type" {
#   description = "The type of the access entry (e.g., user, group)"
#   value       = var.access_entry_type
# }

# output "user_name" {
#   description = "The name of the user for the EKS access entry"
#   value       = var.user_name
# }

# output "access_entry_tags" {
#   description = "Tags for the EKS access entry"
#   value       = var.access_entry_tags
# }

# output "access_policy_namespaces" {
#   description = "Namespaces for the access policy"
#   value       = var.access_policy_namespaces
# }

# output "access_policy_type" {
#   description = "The type of access policy"
#   value       = var.access_policy_type
# }

# output "access_policy_arn" {
#   description = "The ARN of the access policy"
#   value       = var.access_policy_arn
# }

# output "access_policy_principal_arn" {
#   description = "The ARN of the principal for the access policy"
#   value       = var.access_policy_principal_arn
# }




#########################################################   node grp ##################
# Output for the EKS cluster name
# output "eks_cluster_name" {
#   description = "The name of the EKS cluster"
#   value       = aws_eks_cluster.eks_cluster.name
# }

# Output for the EKS Node Group Name
output "eks_node_group_name" {
  description = "The name of the EKS Node Group"
  value       = aws_eks_node_group.eks_node_group.node_group_name
}

# Output for the IAM role ARN of the EKS Node Group
output "eks_node_group_role_arn" {
  description = "The ARN of the IAM role for the EKS Node Group"
  value       = aws_iam_role.eks_node_group_role.arn
}

# Output for the IAM policy ARN attached to the EKS Node Group role
output "eks_node_group_policy_arn" {
  description = "The ARN of the IAM policy attached to the EKS Node Group"
  value       = aws_iam_policy.eks_node_group_policy.arn
}

# Output for the Security Group ID of the EKS Node Group
output "eks_node_group_sg_id" {
  description = "The ID of the security group for the EKS Node Group"
  value       = aws_security_group.eks_node_group.id
}

# Output for the Security Group Name of the EKS Node Group
output "eks_node_group_sg_name" {
  description = "The name of the security group for the EKS Node Group"
  value       = aws_security_group.eks_node_group.name
}

# Output for the Subnet IDs associated with the EKS Node Group
output "eks_node_group_subnet_ids" {
  description = "The list of subnet IDs associated with the EKS Node Group"
  value       = var.subnet_ids
}

# Output for the EC2 SSH Key Name used for Remote Access
output "eks_node_group_ssh_key_name" {
  description = "The SSH key name for EC2 instance access"
  value       = var.ssh_key_name
}

# Output for the AMI type of the EKS Node Group
output "eks_node_group_ami_type" {
  description = "The AMI type for the EKS Node Group"
  value       = var.node_group_ami_type
}

# Output for the EKS Node Group desired size
output "eks_node_group_desired_size" {
  description = "The desired size of the EKS Node Group"
  value       = var.node_group_desired_size
}

# Output for the EKS Node Group minimum size
output "eks_node_group_min_size" {
  description = "The minimum size of the EKS Node Group"
  value       = var.node_group_min_size
}

# Output for the EKS Node Group maximum size
output "eks_node_group_max_size" {
  description = "The maximum size of the EKS Node Group"
  value       = var.node_group_max_size
}

# Output for the instance types used in the EKS Node Group
output "eks_node_group_instance_types" {
  description = "The instance types used in the EKS Node Group"
  value       = var.node_group_instance_types
}

# Output for the VPC ID where the Node Group resides
output "eks_vpc_id" {
  description = "The VPC ID where the EKS Node Group is located"
  value       = var.vpc_id
}
