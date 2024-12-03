# Define the list of clusters to create with their unique configurations
variable "clusters" {
  description = "Map of cluster configurations. Each cluster includes the cluster name and optionally other custom attributes."
  type = map(object({
    cluster_name = string
  }))
}

# Overrides for each cluster configuration to allow customization
variable "custom_overrides" {
  description = "Map of cluster-specific custom configurations to override defaults."
  type = map(object({
    node_ami_id              = optional(string, null)     # AMI ID for EC2 instances
    node_instance_type       = optional(string, null)     # EC2 instance type for nodes
    node_desired_capacity    = optional(number, null)     # Desired number of nodes
    node_max_size            = optional(number, null)     # Maximum number of nodes in the group
    node_min_size            = optional(number, null)     # Minimum number of nodes in the group
    subnet_ids               = optional(list(string), []) # List of subnet IDs for the cluster
    placement_group_strategy = optional(string, null)     # Placement group strategy ('spread', 'cluster', or 'partition')
  }))
  default = {}
}

# Tags to be applied to all resources
variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "EKS Cluster Management"
  }
}

# General default settings for node groups
variable "node_ami_id" {
  description = "Default AMI ID for worker nodes."
  type        = string
  default     = "ami-default"
}

variable "node_instance_type" {
  description = "Default EC2 instance type for worker nodes."
  type        = string
  default     = "t3.medium"
}

variable "node_desired_capacity" {
  description = "Default desired capacity for worker nodes in the Auto Scaling group."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Default maximum size of the Auto Scaling group."
  type        = number
  default     = 5
}

variable "node_min_size" {
  description = "Default minimum size of the Auto Scaling group."
  type        = number
  default     = 1
}

# Placement group settings
variable "placement_group_strategy" {
  description = "Default placement group strategy for worker nodes. Options: 'spread', 'cluster', 'partition'."
  type        = string
  default     = "spread"
}

# VPC and networking settings
variable "vpc_id" {
  description = "The VPC ID where the cluster and worker nodes will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "List of default subnet IDs for worker nodes."
  type        = list(string)
  default     = []
}

variable "node_associate_public_ip" {
  description = "Boolean to indicate whether worker nodes should be associated with public IPs."
  type        = bool
  default     = true
}

# Scaling schedule settings
variable "schedule_scale_out_min" {
  description = "Minimum size for the Auto Scaling group during scale-out."
  type        = number
  default     = 2
}

variable "schedule_scale_out_max" {
  description = "Maximum size for the Auto Scaling group during scale-out."
  type        = number
  default     = 5
}

variable "schedule_scale_out_desired" {
  description = "Desired size for the Auto Scaling group during scale-out."
  type        = number
  default     = 3
}

variable "schedule_scale_in_min" {
  description = "Minimum size for the Auto Scaling group during scale-in."
  type        = number
  default     = 1
}

variable "schedule_scale_in_max" {
  description = "Maximum size for the Auto Scaling group during scale-in."
  type        = number
  default     = 3
}

variable "schedule_scale_in_desired" {
  description = "Desired size for the Auto Scaling group during scale-in."
  type        = number
  default     = 1
}

variable "schedule_scale_out_recurrence" {
  description = "Cron expression for the scale-out schedule."
  type        = string
  default     = "0 6 * * *"
}

variable "schedule_scale_in_recurrence" {
  description = "Cron expression for the scale-in schedule."
  type        = string
  default     = "0 22 * * *"
}

# Define the scaling policies for each cluster
variable "scaling_policies" {
  description = "Scaling policies for each cluster, including scale in/out parameters."
  type = map(object({
    scale_out_min     = number
    scale_out_max     = number
    scale_out_desired = number
    scale_in_min      = number
    scale_in_max      = number
    scale_in_desired  = number
  }))
  default = {}
}


