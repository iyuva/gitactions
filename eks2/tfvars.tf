# Common variables for the configuration
tags = {
  "Environment" = "prod"
  "ManagedBy"   = "Terraform"
}

# Define your cluster configuration here
clusters = {
  cluster1 = {
    cluster_name                  = "my-cluster-1"
    cluster_version               = "1.21"
    cluster_enabled_log_types     = ["api", "audit", "authenticator"]
    bootstrap_self_managed_addons = true
    authentication_mode           = "RBAC"
    vpc_config = {
      vpc_id                  = "vpc-xxxxxx"
      subnet_ids              = ["subnet-xxxxxx", "subnet-yyyyyy"]
      cluster_endpoint_private_access = true
      cluster_endpoint_public_access  = true
      cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
    }
    create_outposts_local_cluster   = false
    cluster_ip_family              = "IPv4"
    cluster_service_ipv4_cidr      = "10.100.0.0/16"
    cluster_service_ipv6_cidr      = "fd00::/48"
    outpost_config = {
      control_plane_instance_type = "m5.large"
      outpost_arns                = ["arn:aws:outposts:region:account-id:outpost/outpost-id"]
    }
    cluster_tags = {
      "Purpose" = "Development"
    }
    cluster_timeouts = {
      create = "30m"
      update = "15m"
      delete = "10m"
    }
  }
  
  # Define other clusters similarly
  cluster2 = {
    cluster_name                  = "my-cluster-2"
    cluster_version               = "1.22"
    cluster_enabled_log_types     = ["api", "audit"]
    bootstrap_self_managed_addons = false
    authentication_mode           = "RBAC"
    vpc_config = {
      vpc_id                  = "vpc-yyyyyy"
      subnet_ids              = ["subnet-zzzzzz", "subnet-wwwwww"]
      cluster_endpoint_private_access = true
      cluster_endpoint_public_access  = false
      cluster_endpoint_public_access_cidrs = []
    }
    create_outposts_local_cluster   = false
    cluster_ip_family              = "IPv4"
    cluster_service_ipv4_cidr      = "10.200.0.0/16"
    cluster_service_ipv6_cidr      = "fd00::/48"
    cluster_tags = {
      "Purpose" = "Staging"
    }
    cluster_timeouts = {
      create = "20m"
      update = "10m"
      delete = "5m"
    }
  }
}

# Enable or disable features
create = true
enable_cluster_creator_admin_permissions = true
create_cluster_security_group = true
create_outposts_local_cluster = false
create_iam_role = true
create_irsa = false
create_cloudwatch_log_group = true

# IAM roles and policies
iam_role_permissions_boundary = "arn:aws:iam::aws:policy/AdministratorAccess"
iam_role_description = "EKS Cluster IAM Role"
iam_role_path = "/"
iam_role_use_name_prefix = true
iam_role_additional_policies = {
  "CustomPolicy" = "arn:aws:iam::aws:policy/CustomPolicy"
}

# CloudWatch Log Group retention
cloudwatch_log_group_retention_in_days = 30
cloudwatch_log_group_kms_key_id = "arn:aws:kms:region:account-id:key/key-id"
cloudwatch_log_group_class = "Standard"

# KMS Key
create_kms_key = false

# Define security group and rules for the cluster
cluster_security_group_description = "EKS Cluster Security Group"
cluster_security_group_tags = {
  "Purpose" = "EKS Cluster"
}

# Custom Tags for Cluster Security Group
cluster_security_group_additional_rules = {
  "allow_ssh" = {
    description = "Allow SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    type        = "ingress"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define your access entries
access_entries = {
  cluster_creator = {
    principal_arn = "arn:aws:iam::account-id:user/username"
    type          = "STANDARD"
    policy_associations = {
      admin = {
        policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type = "cluster"
        }
      }
    }
  }
}

# Addons configuration
cluster_addons = {
  "addon1" = {
    name              = "vpc-cni"
    addon_version     = "v1.10.1"
    configuration_values = "{\"enableIPv6\": true}"
    preserve          = true
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    timeouts = {
      create = "20m"
      update = "10m"
      delete = "5m"
    }
  }
}

# KMS Key Configuration
cluster_encryption_policy_use_name_prefix = false
cluster_encryption_policy_description = "KMS encryption for EKS"
cluster_encryption_policy_tags = {
  "Purpose" = "Encryption"
}

# Enable or disable specific IAM roles and policies
iam_role_use_name_prefix = true
