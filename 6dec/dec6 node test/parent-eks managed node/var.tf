# variables.tf (Parent Module)

variable "node_group_name" {
  type        = string
  description = "Name of the EKS node group."
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the node group."
}

variable "min_size" {
  type        = number
  description = "Minimum number of nodes in the node group."
}

variable "max_size" {
  type        = number
  description = "Maximum number of nodes in the node group."
}

variable "desired_size" {
  type        = number
  description = "Desired number of nodes in the node group."
}

variable "ami_type" {
  type        = string
  description = "Type of AMI for the node group."
  default     = "AL2"
}

variable "release_version" {
  type        = string
  description = "EKS optimized AMI release version."
}

variable "eks_version" {
  type        = string
  description = "Version of Kubernetes for the EKS cluster."
}

variable "capacity_type" {
  type        = string
  description = "Capacity type (on-demand or spot)."
  default     = "ON_DEMAND"
}

variable "disk_size" {
  type        = number
  description = "EBS volume size in GB."
  default     = 20
}

variable "launch_template" {
  type        = bool
  description = "Flag to use launch template."
  default     = false
}

variable "launch_template_id" {
  type        = string
  description = "ID of the launch template."
  default     = ""
}

variable "launch_template_version" {
  type        = string
  description = "Version of the launch template."
  default     = ""
}

variable "remote_access_enabled" {
  type        = bool
  description = "Flag to enable SSH access to the node group."
  default     = false
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name for the node group."
  default     = ""
}

variable "ssh_security_group_ids" {
  type        = list(string)
  description = "Security group IDs for SSH access."
  default     = []
}

variable "taints" {
  type        = list(map(string))
  description = "Taints to be applied to the node group."
  default     = []
}

variable "update_config_enabled" {
  type        = bool
  description = "Flag to enable custom update config for the node group."
  default     = false
}

variable "max_unavailable_percentage" {
  type        = number
  description = "Max unavailable percentage during update."
  default     = 50
}

variable "max_unavailable" {
  type        = number
  description = "Max unavailable nodes during update."
  default     = 1
}

variable "timeouts" {
  type        = map(string)
  description = "Custom timeouts for node group operations."
  default = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags for the node group."
  default     = {}
}

variable "schedules" {
  type        = map(any)
  description = "Schedules for autoscaling."
  default     = {}
}

variable "create_schedule" {
  type        = bool
  description = "Flag to create an autoscaling schedule."
  default     = false
}
