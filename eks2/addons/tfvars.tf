cluster_version = "1.21"

cluster_addons = {
  "vpc-cni" = {
    name                     = "vpc-cni"
    addon_version            = "v1.9.0-eksbuild.1"
    configuration_values     = {}
    pod_identity_association = []
    preserve                 = true
    before_compute           = false
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = null
    timeouts = {
      create = "15m"
      update = "15m"
      delete = "15m"
    }
    tags = {
      "Environment" = "prod"
    }
  }
}

tags = {
  "Project" = "EKS-Cluster"
}
