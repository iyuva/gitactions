# outputs.tf

output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "eks_addon_names" {
  value = module.eks.eks_addon_names
}
