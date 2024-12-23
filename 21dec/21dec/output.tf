# # Outputs (optional, if you want to output useful information)
# output "eks_cluster_names" {
#   value = [for cluster in aws_eks_cluster.eks_cluster : cluster.name]
# }

# output "eks_cluster_role_arns" {
#   value = [for role in aws_iam_role.eks_cluster_role : role.arn]
# }

# output "eks_security_group_ids" {
#   value = [for sg in aws_security_group.eks_sg_dynamic : sg.id]
# }
