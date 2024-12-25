ekscluster = {
  cluster1 = {
    cluster_name                                = "yuva"
    cluster_version                             = "1.31"
    cluster_enabled_log_types                   = ["audit", "api", "authenticator"]
    bootstrap_self_managed_addons               = true
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
    subnet_ids                                  = ["subnet-0f6efc487e9461480", "subnet-0ab4f893f4311cec0"]
    cluster_endpoint_private_access             = true
    cluster_endpoint_public_access              = true
    cluster_endpoint_public_access_cidrs        = ["0.0.0.0/0"]
    enable_kubernetes_network_config            = true
    cluster_ip_family                           = "ipv4"
    cluster_service_ipv4_cidr                   = "10.100.0.0/16"
    enable_cluster_encryption_config            = true
    # cluster_encryption_config          = {
    #   provider_key_arn = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-5678-90ab-cdef-1234567890ab"
    #   resources        = ["secrets"]
    # }
    enable_upgrade_policy = EXTENDED
    # upgrade_max_unavailable            = 2
    enable_zonal_shift = true
    #zonal_shift_enabled = true
    # zonal_shift_zone                   = "us-west-2a"
    tags = { "Environment" = "Production", "Project" = "EKS" }
    cluster_timeouts = {
      create = "40m"
      update = "30m"
      delete = "35m"
    }
  }
}

vpc_id       = "vpc-0fb09ca9d377d7c4f"
cluster_name = "yuva"
