# terraform.tfvars

clusters = {
  "cluster1" = {
    cluster_name                 = "eks-cluster-1"
    cluster_version              = "1.21"
    cluster_enabled_log_types    = ["api", "audit"]
    bootstrap_self_managed_addons = true
    authentication_mode          = "AWS_IAM"
    vpc_config = {
      vpc_id                            = "vpc-12345678"
      subnet_ids                        = ["subnet-abc123", "subnet-def456"]
      cluster_endpoint_private_access   = true
      cluster_endpoint_public_access    = true
      cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
    }
    create_outposts_local_cluster = false
    cluster_ip_family            = "IPv4"
    cluster_service_ipv4_cidr    = "172.20.0.0/16"
    cluster_service_ipv6_cidr    = "fd00::/56"
    outpost_config = {
      control_plane_instance_type = "m5.large"
      outpost_arns                = ["arn:aws:outposts:region:account-id:outpost/outpost-id"]
    }
    cluster_encryption_config    = [
      {
        provider_key_arn = "arn:aws:kms:region:account-id:key/key-id"
        resources        = ["secrets"]
      }
    ]
    cluster_upgrade_policy       = [
      {
        support_type = "EKS"
      }
    ]
    cluster_zonal_shift_config   = []
    tags                         = {
      "Environment" = "dev"
    }
    cluster_tags                 = {}
    cluster_timeouts             = {
      create = "30m"
      update = "20m"
      delete = "30m"
    }
  }

  "cluster2" = {
    cluster_name                 = "eks-cluster-2"
    cluster_version              = "1.22"
    cluster_enabled_log_types    = ["api", "audit"]
    bootstrap_self_managed_addons = false
    authentication_mode          = "IAM Identity Provider"
    vpc_config = {
      vpc_id                            = "vpc-23456789"
      subnet_ids                        = ["subnet-xyz789", "subnet-uvw012"]
      cluster_endpoint_private_access   = false
      cluster_endpoint_public_access    = true
      cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
    }
    create_outposts_local_cluster = true
    cluster_ip_family            = "IPv6"
    cluster_service_ipv4_cidr    = "172.20.0.0/16"
    cluster_service_ipv6_cidr    = "fd00::/56"
    outpost_config = {
      control_plane_instance_type = "t3.medium"
      outpost_arns                = ["arn:aws:outposts:region:account-id:outpost/outpost-id"]
    }
    cluster_encryption_config    = []
    cluster_upgrade_policy       = []
    cluster_zonal_shift_config   = [
      {
        enabled = true
      }
    ]
    tags                         = {
      "Environment" = "prod"
    }
    cluster_tags                 = {}
    cluster_timeouts             = {
      create = "25m"
      update = "20m"
      delete = "30m"
    }
  }
}

local_cluster_role = "arn:aws:iam::account-id:role/eks-cluster-role"

kms = {
  key_arn = "arn:aws:kms:region:account-id:key/key-id"
}





################ cloud watach and ec2tags #####


# terraform.tfvars

tags = {
  "Environment" = "prod"
  "Team"        = "DevOps"
}

cluster_tags = {
  "Cluster" = "eks-cluster"
}

create_cluster_primary_security_group_tags = true

create_cloudwatch_log_group = true

cloudwatch_log_group_retention_in_days = 30

cloudwatch_log_group_kms_key_id = "arn:aws:kms:region:account-id:key/key-id"

cloudwatch_log_group_class = "Standard"

create = true

vpc_id = "vpc-xxxxxxxx"

cluster_name = "my-cluster"



##########Acess entry #########

# Provide default values for the variables used in the module

create                           = true
enable_cluster_creator_admin_permissions = true

access_entries = {
  "admin_user" = {
    principal_arn      = "arn:aws:iam::123456789012:user/AdminUser"
    type               = "STANDARD"
    kubernetes_groups  = ["system:masters"]
    user_name          = "AdminUser"
    tags               = {
      "Environment" = "Production"
    }
    policy_associations = {
      "admin" = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type       = "cluster"
          namespaces = ["default", "kube-system"]
        }
      }
    }
  }
}

tags = {
  "Project"   = "EKS Cluster"
  "Owner"     = "Team"
  "Environment" = "Production"
}




#############cluster security grp 

# Provide default values for the variables used in the module

create                            = true
create_cluster_security_group     = true
cluster_name                      = "my-cluster"
cluster_security_group_name       = "my-cluster-sg"
cluster_security_group_description = "Security group for EKS cluster"
vpc_id                            = "vpc-xxxxxxxx"
tags                              = {
  "Environment" = "Production"
  "Owner"       = "Team"
}

cluster_security_group_additional_rules = {
  ingress_http = {
    description         = "Allow HTTP access"
    protocol            = "tcp"
    from_port           = 80
    to_port             = 80
    type                = "ingress"
    cidr_blocks         = ["0.0.0.0/0"]
    ipv6_cidr_blocks    = []
    prefix_list_ids     = []
    self                = false
    source_security_group_id = ""
  }
}

node_security_group_id = "sg-xxxxxxxx"



################ IRSA

# Provide values for the variables used in the module

create                         = true
enable_irsa                    = true
create_outposts_local_cluster  = false
include_oidc_root_ca_thumbprint = true

custom_oidc_thumbprints        = ["custom_thumbprint1", "custom_thumbprint2"]
openid_connect_audiences       = ["sts.amazonaws.com"]

tags = {
  "Environment" = "Production"
  "Owner"       = "Team"
}

cluster_name = "my-cluster"





################   IAM 

# Provide values for the variables used in the module

clusters = {
  "cluster1" = {
    cluster_name                      = "cluster1"
    create_outposts_local_cluster     = false
    enable_cluster_encryption_config  = true
    cluster_encryption_config = {
      provider_key_arn = "arn:aws:kms:region:account-id:key/key-id"
    }
  },
  "cluster2" = {
    cluster_name                      = "cluster2"
    create_outposts_local_cluster     = true
    enable_cluster_encryption_config  = true
    cluster_encryption_config = {
      provider_key_arn = "arn:aws:kms:region:account-id:key/key-id"
    }
  }
}

create_iam_role                    = true
iam_role_use_name_prefix           = false
iam_role_path                      = "/"
iam_role_description               = "IAM role for EKS cluster"
iam_role_permissions_boundary       = ""
tags                               = {
  "Environment" = "Production"
  "Owner"       = "Team"
}
iam_role_tags                      = {
  "CreatedBy" = "Terraform"
}
iam_role_policy_prefix             = "aws-eks-"
iam_role_additional_policies       = {
  "CustomPolicy1" = "arn:aws:iam::aws:policy/CustomPolicy1"
}

attach_cluster_encryption_policy   = true
cluster_encryption_policy_use_name_prefix = false
cluster_encryption_policy_description = "Cluster encryption policy"
cluster_encryption_policy_path    = "/"
create_kms_key                    = true
kms_key_arn                        = "arn:aws:kms:region:account-id:key/key-id"
enable_cluster_encryption_config  = true




###########################  EKS Addons 

# Provide values for the variables defined in `variables.tf`

cluster_addons = {
  "addon1" = {
    name                         = "vpc-cni"
    addon_version                = "v1.10.0-eksbuild.1"
    most_recent                  = true
    configuration_values        = {}
    pod_identity_association    = []
    preserve                    = true
    before_compute              = false
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn    = "arn:aws:iam::123456789012:role/eks-service-account-role"
    timeouts = {
      create = "20m"
      update = "20m"
      delete = "10m"
    }
    tags = {
      "Environment" = "production"
      "Owner"       = "team"
    }
  },
  "addon2" = {
    name                         = "core-dns"
    addon_version                = "v1.8.0-eksbuild.1"
    most_recent                  = true
    configuration_values        = {}
    pod_identity_association    = []
    preserve                    = false
    before_compute              = true
    resolve_conflicts_on_create = "NONE"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn    = null
    timeouts = {
      create = "30m"
      update = "30m"
      delete = "15m"
    }
    tags = {
      "Environment" = "staging"
      "Owner"       = "ops"
    }
  }
}

create                          = true
create_outposts_local_cluster   = false
cluster_version                 = "1.21"
tags                            = {
  "Project" = "EKS Addons"
  "Team"    = "DevOps"
}
cluster_addons_timeouts = {
  create = "30m"
  update = "30m"
  delete = "15m"
}

bootstrap_self_managed_addons = true



############################################# eks identifiers provider 

# Provide values for the variables defined in `variables.tf`

# cluster_identity_providers = {
#   "oidc-provider-1" = {
#     client_id                     = "sts.amazonaws.com"
#     identity_provider_config_name = "oidc-provider-1"
#     issuer_url                    = "https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLE"
#     groups_claim                  = "groups"
#     groups_prefix                 = "oidc-group"
#     required_claims               = {
#       "claim1" = "value1"
#       "claim2" = "value2"
#     }
#     username_claim                = "sub"
#     username_prefix               = "oidc-user-"
#     tags                          = {
#       "Environment" = "production"
#       "Team"        = "security"
#     }
#   },

#   "oidc-provider-2" = {
#     client_id                     = "sts.amazonaws.com"
#     identity_provider_config_name = "oidc-provider-2"
#     issuer_url                    = "https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"
#     groups_claim                  = "groups"
#     groups_prefix                 = "oidc-group"
#     required_claims               = {
#       "claim1" = "value1"
#       "claim2" = "value2"
#     }
#     username_claim                = "sub"
#     username_prefix               = "oidc-user-"
#     tags                          = {
#       "Environment" = "development"
#       "Team"        = "engineering"
#     }
#   }
# }

# create                        = true
# create_outposts_local_cluster = false
# cluster_version               = "1.30"
# tags                          = {
#   "Project" = "EKS Identity Providers"
#   "Owner"   = "team"
# }









