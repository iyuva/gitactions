# modules/eks/outputs.tf

output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}

output "eks_addon_names" {
  value = [for addon in aws_eks_addon.addon : addon.addon_name]
}





##########
output "eks_addon_names" {
  value = [for addon in aws_eks_addon.this : addon.addon_name]
}
