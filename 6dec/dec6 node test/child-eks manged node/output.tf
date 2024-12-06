##################################
# Output for IAM Role ARN
##################################
output "eks_node_role_arn" {
  description = "The ARN of the EKS node IAM role"
  value       = aws_iam_role.eks_node_role.arn
}

##################################
# Output for IAM Policy ARN
##################################
output "eks_node_policy_arn" {
  description = "The ARN of the EKS node IAM policy"
  value       = aws_iam_policy.eks_node_policy.arn
}

##################################
# Output for Node Group Name
##################################
output "eks_node_group_name" {
  description = "The name of the EKS node group"
  value       = aws_eks_node_group.this.node_group_name
}

##################################
# Output for Node Group Instance Role ARN
##################################
output "eks_node_group_instance_role_arn" {
  description = "The ARN of the instance role for the EKS node group"
  value       = aws_iam_role.eks_node_role.arn
}

##################################
# Output for Security Group ID
##################################
output "eks_node_security_group_id" {
  description = "The ID of the security group associated with the EKS node group"
  value       = aws_security_group.eks_node_sg.id
}

##################################
# Output for Node Group Subnet IDs
##################################
output "eks_node_group_subnet_ids" {
  description = "The list of subnet IDs associated with the EKS node group"
  value       = aws_eks_node_group.this.subnet_ids
}

##################################
# Output for Autoscaling Group Name
##################################
output "eks_autoscaling_group_name" {
  description = "The name of the autoscaling group for the EKS node group"
  value       = aws_eks_node_group.this.resources[0].autoscaling_groups[0].name
}

##################################
# Output for EKS Cluster Name
##################################
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = var.cluster_name
}

##################################
# Output for Node Group Tags
##################################
output "node_group_tags" {
  description = "The tags applied to the EKS node group EC2 instances"
  value       = var.node_group_tags
}
