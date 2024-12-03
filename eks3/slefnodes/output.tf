output "cluster_ids" {
  description = "Map of cluster names and their IDs."
  value       = { for key, cluster in aws_eks_cluster.this : key => cluster.id }
}

output "node_group_ids" {
  description = "Map of cluster names and their Auto Scaling group IDs."
  value       = { for key, group in aws_autoscaling_group.self_managed_node_group : key => group.id }
}

output "launch_template_ids" {
  description = "Map of cluster names and their EC2 Launch Template IDs."
  value       = { for key, template in aws_launch_template.self_managed_node_group : key => template.id }
}

output "security_group_ids" {
  description = "Map of cluster names and their associated Security Group IDs."
  value       = { for key, sg in aws_security_group.self_managed_node_group : key => sg.id }
}
