# main.tf (Parent Module)

module "eks_node_group" {
  source = "./eks-node-group" # Assuming the child module is in the `eks-node-group` directory

  # Required variables for the node group
  node_group_name            = var.node_group_name
  cluster_name               = var.cluster_name
  subnet_ids                 = var.subnet_ids
  min_size                   = var.min_size
  max_size                   = var.max_size
  desired_size               = var.desired_size
  ami_type                   = var.ami_type
  release_version            = var.release_version
  eks_version                = var.eks_version
  capacity_type              = var.capacity_type
  disk_size                  = var.disk_size
  launch_template            = var.launch_template
  launch_template_id         = var.launch_template_id
  launch_template_version    = var.launch_template_version
  remote_access_enabled      = var.remote_access_enabled
  ssh_key_name               = var.ssh_key_name
  ssh_security_group_ids     = var.ssh_security_group_ids
  taints                     = var.taints
  update_config_enabled      = var.update_config_enabled
  max_unavailable_percentage = var.max_unavailable_percentage
  max_unavailable            = var.max_unavailable
  timeouts                   = var.timeouts
  tags                       = var.tags
  schedules                  = var.schedules
  create_schedule            = var.create_schedule
}

# output "eks_node_group_id" {
#   value = module.eks_node_group.eks_node_group_id
# }
