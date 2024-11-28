# output.tf

# Output the names of all created EKS clusters
output "eks_cluster_names" {
  description = "List of names of the created EKS clusters"
  value       = [for cluster in aws_eks_cluster.this : cluster.name]
}

# Output the ARNs of all created EKS clusters
output "eks_cluster_arns" {
  description = "List of ARNs of the created EKS clusters"
  value       = [for cluster in aws_eks_cluster.this : cluster.arn]
}

# Output the Kubernetes API server endpoint for each EKS cluster
output "eks_cluster_endpoint" {
  description = "The Kubernetes API server endpoint for each EKS cluster"
  value       = [for cluster in aws_eks_cluster.this : cluster.endpoint]
}

# Output the role ARN for each EKS cluster
output "eks_cluster_role_arn" {
  description = "IAM role ARN used by the EKS clusters"
  value       = [for cluster in aws_eks_cluster.this : cluster.role_arn]
}

# Output the VPC ID associated with each EKS cluster
output "eks_cluster_vpc_id" {
  description = "VPC ID associated with each EKS cluster"
  value       = [for cluster in aws_eks_cluster.this : cluster.vpc_config[0].vpc_id]
}

# Output the subnet IDs associated with each EKS cluster
output "eks_cluster_subnet_ids" {
  description = "List of subnet IDs for each EKS cluster"
  value       = [for cluster in aws_eks_cluster.this : cluster.vpc_config[0].subnet_ids]
}

# Output the enabled log types for each EKS cluster
output "eks_cluster_enabled_log_types" {
  description = "The enabled log types for each EKS cluster"
  value       = [for cluster in aws_eks_cluster.this : cluster.enabled_cluster_log_types]
}

# Output the encryption configuration for each EKS cluster
output "eks_cluster_encryption_config" {
  description = "The encryption configuration for each EKS cluster"
  value       = [for cluster in aws_eks_cluster.this : cluster.encryption_config]
}

# Output the tags applied to each EKS cluster
output "eks_cluster_tags" {
  description = "Tags applied to each EKS cluster"
  value       = [for cluster in aws_eks_cluster.this : cluster.tags]
}

# Output the timeouts configured for each EKS cluster
output "eks_cluster_timeouts" {
  description = "Timeouts for each EKS cluster creation, update, and deletion"
  value       = [for cluster in aws_eks_cluster.this : cluster.timeouts]
}



################ cloud watch 


output "cluster_security_group_id" {
  description = "The ID of the EKS cluster primary security group."
  value       = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.this.*.name
}


########Access entry ######

# Define outputs to display relevant resource details

output "eks_access_entries" {
  description = "The list of access entries created for the EKS cluster."
  value       = aws_eks_access_entry.this
}

output "eks_access_policy_associations" {
  description = "The list of policy associations created for the EKS cluster."
  value       = aws_eks_access_policy_association.this
}



###############cluster security grp 
# Define outputs to display relevant resource details

output "cluster_security_group_id" {
  description = "The ID of the EKS cluster security group."
  value       = aws_security_group.cluster[0].id
}

output "cluster_security_group_rules" {
  description = "The security group rules associated with the EKS cluster."
  value       = aws_security_group_rule.cluster
}




################ IRSA 
# Define outputs for the resources

output "oidc_provider_url" {
  description = "The URL of the OpenID Connect provider."
  value       = aws_iam_openid_connect_provider.oidc_provider[0].url
}

output "oidc_provider_thumbprints" {
  description = "The thumbprints used in the OpenID Connect provider."
  value       = aws_iam_openid_connect_provider.oidc_provider[0].thumbprint_list
}


###################################   IAM 

# Define outputs for IAM roles and policies

output "iam_role_names" {
  description = "The names of the IAM roles created."
  value       = { for k, v in aws_iam_role.this : k => v.name }
}

output "cluster_encryption_policy_arns" {
  description = "The ARNs of the cluster encryption policies created."
  value       = { for k, v in aws_iam_policy.cluster_encryption : k => v.arn }
}



###################### EKS Addons 

# Outputs for EKS addon management

output "eks_addon_versions" {
  description = "The versions of the EKS addons."
  value       = { for k, v in data.aws_eks_addon_version.this : k => v.version }
}

output "eks_addon_arns" {
  description = "The ARNs of the EKS addons."
  value       = { for k, v in aws_eks_addon.this : k => v.arn }
}

output "eks_addon_before_compute_arns" {
  description = "The ARNs of the EKS addons with before_compute flag."
  value       = { for k, v in aws_eks_addon.before_compute : k => v.arn }
}







####################################################### EKS identity_provider 


# Outputs for EKS identity provider configurations

# output "eks_identity_provider_config_names" {
#   description = "The names of the created identity provider configurations."
#   value       = { for k, v in aws_eks_identity_provider_config.this : k => v.identity_provider_config_name }
# }

# output "eks_identity_provider_tags" {
#   description = "Tags for each identity provider configuration."
#   value       = { for k, v in aws_eks_identity_provider_config.this : k => v.tags }
# }




##############





