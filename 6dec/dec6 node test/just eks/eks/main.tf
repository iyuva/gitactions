provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "eks_cluster" {
  source                     = "C:/Users/venkat/Desktop/New folder (2)/eks5 dec4/with eks managednode latest/child"
  cluster_name               = var.cluster_name
  cluster_version            = var.cluster_version
  enabled_log_types          = var.enabled_log_types
  bootstrap_addons           = var.bootstrap_addons
  subnet_ids                 = var.subnet_ids
  vpc_id                     = var.vpc_id
  security_group_protocol    = var.security_group_protocol
  security_group_from_port   = var.security_group_from_port
  security_group_to_port     = var.security_group_to_port
  security_group_type        = var.security_group_type
  security_group_description = var.security_group_description
  security_group_cidr_blocks = var.security_group_cidr_blocks
  ssh_key_name               = var.ssh_key_name
  node_group_ami_type        = var.node_group_ami_type
  node_group_desired_size    = var.node_group_desired_size
  node_group_min_size        = var.node_group_min_size
  node_group_max_size        = var.node_group_max_size
  node_group_instance_types  = var.node_group_instance_types
  default_tags               = var.default_tags
  cluster_timeouts           = var.cluster_timeouts
}
