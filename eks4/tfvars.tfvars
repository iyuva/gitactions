# VPC ID for the security group and EKS cluster
vpc_id = "vpc-0ab4c584c0238321c"

# Default tags for resources
default_tags = {
  "Environment" = "Production"
  "Owner"       = "Team XYZ"
}

# # Cluster-specific information
# cluster_names = {
#   "eks-cluster-1" = {
#     version                     = "1.31"
#     enabled_log_types           = ["api", "audit", "authenticator"]
#     bootstrap_addons            = true
#     authentication_mode         = "aws-iam"
#     cluster_creator_permissions = true
#     subnet_ids                  = ["subnet-12345678", "subnet-87654321"]
#     endpoint_private_access     = true
#     endpoint_public_access      = true
#     public_access_cidrs         = ["0.0.0.0/0"]
#     cluster_timeouts = {
#       create = "45m"
#       update = "30m"
#       delete = "20m"
#     }
#   }
# }

cluster_names = {
  "eks-cluster-1" = {
    version                     = "1.31"
    enabled_log_types           = ["api", "audit", "authenticator"]
    bootstrap_addons            = true
    authentication_mode         = "API_AND_CONFIG_MAP" #["API" "API_AND_CONFIG_MAP" "CONFIG_MAP"]
    cluster_creator_permissions = true
    subnet_ids                  = ["subnet-03056328925786721", "subnet-03047d20966e654cb"]
    endpoint_private_access     = true
    endpoint_public_access      = true
    public_access_cidrs         = ["0.0.0.0/0"]
    cluster_timeouts = {
      create = "45m"
      update = "30m"
      delete = "20m"
    }
    security_group_ids = ["sg-04c98694c57c15caf"] # Add your security group IDs here
  }
  "eks-cluster-2" = {
    version                     = "1.31"
    enabled_log_types           = ["api", "audit", "authenticator"]
    bootstrap_addons            = true
    authentication_mode         = "API_AND_CONFIG_MAP" #["API" "API_AND_CONFIG_MAP" "CONFIG_MAP"]
    cluster_creator_permissions = true
    subnet_ids                  = ["subnet-03056328925786721", "subnet-03047d20966e654cb"]
    endpoint_private_access     = true
    endpoint_public_access      = true
    public_access_cidrs         = ["0.0.0.0/0"]
    cluster_timeouts = {
      create = "45m"
      update = "30m"
      delete = "20m"
    }
    security_group_ids = ["sg-04c98694c57c15caf"] # Add your security group IDs here
  }
}





# eks_addons = {
#   "addon-1" = {
#     addon_name    = "vpc-cni"
#     addon_version = "v1.8.0-eksbuild.1"
#     configuration_values = {
#       "kubelet-extra-args" = "--node-labels=eks.amazonaws.com/compute-type=on-demand"
#     }
#     pod_identity_association = {
#       service_account = "addon-service-account"
#     }
#     preserve                    = true
#     resolve_conflicts_on_create = "OVERWRITE"
#     resolve_conflicts_on_update = "OVERWRITE"
#     service_account_role_arn    = "arn:aws:iam::123456789012:role/service-role/eks-addon-role"
#     timeouts = {
#       create = "20m"
#       update = "15m"
#       delete = "20m"
#     }
#     tags = {
#       "Environment" = "Production"
#     }
#   }
# }

# Security group rules for EKS control plane
# security_group_rules = {
#   "ingress_rule_1" = {
#     protocol    = "tcp"
#     from_port   = 443
#     to_port     = 443
#     type        = "ingress"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow inbound HTTPS traffic"
#   }
# }

security_group_rules = {
  "ingress_rule_1" = {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    type        = "ingress"
    cidr_blocks = ["0.0.0.0/0"] # Ensure this is provided
    description = "Allow HTTP"
  }
  "ingress_rule_2" = {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    type             = "ingress"
    ipv6_cidr_blocks = ["::/0"] # Ensure this is provided if using IPv6
    description      = "Allow HTTPS"
  }
}


# Subnet IDs for EKS cluster
subnet_ids = [
  "subnet-03056328925786721",
  "subnet-03047d20966e654cb"
]



# EKS access entries (e.g., users or roles for EKS access)
cluster_access_entries = {
  "eks-cluster-1" = {
    kubernetes_groups = ["system:masters"]
    principal_arn     = "arn:aws:iam::123456789012:role/ExampleRole"
    type              = "EC2" #["EC2" "EC2_LINUX" "EC2_WINDOWS" "FARGATE_LINUX" "HYBRID_LINUX" "STANDARD"]
    user_name         = "example-user"
    tags = {
      "Role" = "Administrator"
    }
  }
}

# EKS access policy associations
cluster_access_policy_associations = {
  "eks-cluster-1" = {
    namespaces    = ["default"]
    type          = "Role"
    policy_arn    = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    principal_arn = "arn:aws:iam::123456789012:role/ExampleRole"
  }
}

# # Addons for the EKS cluster
# eks_addons = {
#   "addon-1" = {
#     addon_name           = "vpc-cni"
#     addon_version        = "v1.8.0-eksbuild.1"
#     configuration_values = "{\"kubelet-extra-args\":\"--node-labels=eks.amazonaws.com/compute-type=on-demand\"}"
#     pod_identity_association = {
#       service_account = "addon-service-account"
#     }
#     preserve                    = true
#     resolve_conflicts_on_create = "OVERWRITE"
#     resolve_conflicts_on_update = "OVERWRITE"
#     service_account_role_arn    = "arn:aws:iam::123456789012:role/service-role/eks-addon-role"
#     timeouts = {
#       create = "20m"
#       update = "15m"
#       delete = "20m"
#     }
#     tags = {
#       "Environment" = "Production"
#     }
#   }
# }

# Identity Provider configuration for EKS
eks_identity_provider_configs = {
  "oidc-provider" = {
    client_id                     = "example-client-id"
    issuer_url                    = "https://example.com/oidc"
    identity_provider_config_name = "oidc-provider"
    groups_claim                  = "groups"
    groups_prefix                 = "oidc"
    required_claims               = ["aud", "exp"]
    username_claim                = "sub"
    username_prefix               = "oidc"
    tags = {
      "Environment" = "Production"
    }
  }
}

# EKS control plane security group tags
cluster_security_group_tags = {
  "Name" = "eks-control-plane-sg"
}

# IAM Role for the EKS cluster (used in the IAM policy attachment)
eks_role = {
  role_name = "eks-cluster-role"
}

# KMS Encryption for the cluster (if enabled)
create_kms_key = false
cluster_encryption_config = {
  provider_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abcd-1234-xyz"
  resources        = ["secrets"]
}

# EKS Upgrade policy (optional)
cluster_upgrade_policy = {
  support_type = "STANDARD" #EXTENDED
}

# Zonal shift configuration (optional)
cluster_zonal_shift_config = {
  enabled = true
}

# Outpost config (optional)
outpost_config = {
  control_plane_instance_type = "t3.medium"
  outpost_arns                = ["arn:aws:outposts:us-westeast-1:123456789012:outpost/op-0123456789abcdef0"]
}

# IP family for the cluster network (optional)
cluster_ip_family         = "ipv4"
cluster_service_ipv4_cidr = "172.20.0.0/16"
#cluster_service_ipv6_cidr = "fd00:1234:abcd::/48"
