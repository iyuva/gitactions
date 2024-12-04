####################################
## IAM Outputs
####################################

output "eks_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  value       = aws_iam_role.eks_role.arn
}

output "eks_policy_arn" {
  description = "The ARN of the IAM policy for the EKS cluster"
  value       = aws_iam_policy.eks_policy.arn
}

####################################
## EKS Cluster Outputs
####################################

# output "eks_cluster_name" {
#   description = "The name of the EKS cluster"
#   value       = aws_eks_cluster.eks_cluster[*].name
# }

# output "eks_cluster_endpoint" {
#   description = "The endpoint of the EKS cluster"
#   value       = aws_eks_cluster.eks_cluster[*].endpoint
# }

# output "eks_cluster_arn" {
#   description = "The ARN of the EKS cluster"
#   value       = aws_eks_cluster.eks_cluster[*].arn
# }

####################################
## Security Group Outputs
####################################

output "eks_security_group_id" {
  description = "The security group ID for the EKS control plane"
  value       = aws_security_group.eks_control_plane.id
}

output "eks_subnet_ids" {
  description = "The subnet IDs used by the EKS cluster"
  value       = var.subnet_ids
}

####################################
## EKS Addon Outputs
####################################

# output "eks_addon_names" {
#   description = "Names of the EKS addons deployed"
#   value       = aws_eks_addon.eks_addon[*].addon_name
# }

# output "eks_addon_versions" {
#   description = "Versions of the EKS addons deployed"
#   value       = aws_eks_addon.eks_addon[*].addon_version
# }

####################################
## Identity Provider Config Outputs
####################################

# output "eks_identity_provider_config_names" {
#   description = "Names of the EKS identity provider configurations"
#   value       = aws_eks_identity_provider_config.eks_identity_provider[*].identity_provider_config_name
# }



# output "eks_cluster_name" {
#   value = [for cluster in aws_eks_cluster.eks_cluster : cluster.value.name]
# }

# output "eks_cluster_endpoint" {
#   value = [for cluster in aws_eks_cluster.eks_cluster : cluster.value.endpoint]
# }

# output "eks_cluster_arn" {
#   value = [for cluster in aws_eks_cluster.eks_cluster : cluster.value.arn]
# }

output "eks_cluster_name" {
  value = [for cluster_key, cluster in aws_eks_cluster.eks_cluster : cluster.name]
}

output "eks_cluster_endpoint" {
  value = [for cluster_key, cluster in aws_eks_cluster.eks_cluster : cluster.endpoint]
}

output "eks_cluster_arn" {
  value = [for cluster_key, cluster in aws_eks_cluster.eks_cluster : cluster.arn]
}
