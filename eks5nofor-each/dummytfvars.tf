# #######################
# # AWS Provider Configuration
# #######################

# aws_region     = "us-east-1"           # Adjust to your preferred AWS region
# aws_access_key = "AKIA2EKS7QO234XESMWG" # Your AWS access key
# aws_secret_key = "mOI8+jt3A59af4GviJ/753qy7RsvZW16spqeiw5C" # Your AWS secret key

# #######################
# # IAM Resources
# #######################

# eks_role_name          = "eks-cluster-role"
# eks_policy_name        = "eks-cluster-policy"
# eks_policy_description = "Policy for managing EKS Cluster"
# default_tags = {
#   Environment = "production"
#   ManagedBy   = "Terraform"
# }

# #######################
# # EKS Cluster Configuration
# #######################

# cluster_name                = yu-eks-1"
# cluster_version             = "1.31"
# enabled_log_types           = ["api", "audit", "authenticator"]
# bootstrap_addons            = true
# authentication_mode         = "API_AND_CONFIG_MAP"
# cluster_creator_permissions = true

# subnet_ids                  = ["subnet-09de5b4c07f995ecf", "subnet-07b0e9cf0eb07a197"] # Replace with your subnet IDs
# endpoint_private_access     = true
# endpoint_public_access      = true
# public_access_cidrs         = ["0.0.0.0/0"]
# cluster_ip_family           = "IPv4"
# cluster_service_ipv4_cidr   = "172.20.0.0/16"
# cluster_upgrade_policy      = "EAGER"
# cluster_zonal_shift_enabled = false

# cluster_timeouts = {
#   create = "30m"
#   update = "20m"
#   delete = "15m"
# }

# #######################
# # Security Groups for EKS Cluster
# #######################

# eks_security_group_name    = "eks-control-plane-sg"
# vpc_id                     = "vpc-09476469611f17264" # Replace with your VPC ID
# security_group_protocol    = "tcp"
# security_group_from_port   = 443
# security_group_to_port     = 443
# security_group_type        = "ingress"
# security_group_description = "Allow traffic to EKS control plane"
# security_group_cidr_blocks = ["0.0.0.0/0"] # Adjust as needed

# #######################
# # EC2 Tags for EKS Resources
# #######################

# subnet_name = "my-eks-subnet"

# # ######################
# # IAM Roles and Policies for Addons
# # ######################

# # addon_names = ["vpc-cni", "kube-proxy", "core-dns"] # Example EKS addons
# # addon_versions = {
# #   "vpc-cni"    = "v1.7.5"
# #   "kube-proxy" = "v1.21.2"
# #   "core-dns"   = "v1.8.6"
# # }

# # #######################
# # # OIDC Identity Provider Configuration
# # #######################

# # oidc_client_id       = "my-oidc-client-id"
# # oidc_groups_claim    = "groups"
# # oidc_groups_prefix   = "eks"
# # oidc_config_name     = "my-oidc-config"
# # oidc_issuer_url      = "https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLE"
# # oidc_required_claims = ["aud", "iss"]
# # oidc_username_claim  = "sub"
# # oidc_username_prefix = "eks-user"
# # oidc_tags = {
# #   Project = "eks-oidc"
# # }

# #######################
# # EKS Access Entry AND Policy Association
# #######################

# kubernetes_groups = ["system:masters"]
# principal_arn     = "arn:aws:iam::123456789012:role/eks-admin-role"
# access_entry_type = "User"
# user_name         = "john.doe"
# access_entry_tags = {
#   Role = "admin"
# }

# access_policy_namespaces    = ["default", "kube-system"]
# access_policy_type          = "Allow"
# access_policy_arn           = "arn:aws:iam::123456789012:policy/EKS-Access-Policy"
# access_policy_principal_arn = "arn:aws:iam::123456789012:role/eks-policy-principal"
