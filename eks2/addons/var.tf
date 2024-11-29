# modules/eks/variables.tf

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_role_arn" {
  description = "The IAM role ARN for the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "addons" {
  description = "Map of EKS add-ons to create with their configurations."
  type = map(object({
    version                    = string
    service_account_role_arn   = string
    config                     = map(string) # Optional add-on config
  }))
}




#####################
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "cluster_addons" {
  description = "Map of EKS addons and their configurations"
  type = map(object({
    name                       = string
    addon_version              = string
    configuration_values       = map(string)
    pod_identity_association   = list(object({
      role_arn        = string
      service_account = string
    }))
    preserve                  = bool
    before_compute            = bool
    resolve_conflicts_on_create = string
    resolve_conflicts_on_update = string
    service_account_role_arn   = string
    timeouts                  = object({
      create = string
      update = string
      delete = string
    })
    tags                       = map(string)
  }))
}

variable "bootstrap_self_managed_addons" {
  description = "Flag to control self-managed addon creation"
  type        = bool
  default     = true
}

variable "create" {
  description = "Flag to indicate if resources should be created"
  type        = bool
  default     = true
}

variable "create_outposts_local_cluster" {
  description = "Flag to indicate if resources should be created for outposts local cluster"
  type        = bool
  default     = false
}

variable "cluster_addons_timeouts" {
  description = "Timeouts for cluster addons creation, update, and deletion"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

