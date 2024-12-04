#######################
# AWS Provider Configuration
#######################



#######################
# IAM Resources
#######################

eks_role_name          = "eks-cluster-role"
eks_policy_name        = "eks-cluster-policy"
eks_policy_description = "Policy for managing EKS Cluster"
default_tags = {
  Environment = "production"
  ManagedBy   = "Terraform"
}

#######################
# EKS Cluster Configuration
#######################

cluster_name                = "yu-eks-1"
cluster_version             = "1.31"
enabled_log_types           = ["api", "audit", "authenticator"]
bootstrap_addons            = true
authentication_mode         = "API_AND_CONFIG_MAP"
cluster_creator_permissions = true

subnet_ids                  = ["subnet-09de5b4c07f995ecf", "subnet-07b0e9cf0eb07a197"] # Replace with your subnet IDs
endpoint_private_access     = true
endpoint_public_access      = true
public_access_cidrs         = ["0.0.0.0/0"]
cluster_ip_family           = "IPv4"
cluster_service_ipv4_cidr   = "172.20.0.0/16"
cluster_upgrade_policy      = "EAGER"
cluster_zonal_shift_enabled = false

cluster_timeouts = {
  create = "30m"
  update = "20m"
  delete = "15m"
}



eks_security_group_name    = "eks-control-plane-sg"
vpc_id                     = "vpc-09476469611f17264" # Replace with your VPC ID
security_group_protocol    = "tcp"
security_group_from_port   = 443
security_group_to_port     = 443
security_group_type        = "ingress"
security_group_description = "Allow traffic to EKS control plane"
security_group_cidr_blocks = ["0.0.0.0/0"] # Adjust as needed
