# variables.tf

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
