##########################
# Terraform Variables
##########################

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "my-node-group"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the node group"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
  default     = 1
  validation {
    condition     = var.min_size >= 1
    error_message = "The minimum size must be at least 1."
  }
}

variable "max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
  default     = 3
  validation {
    condition     = var.max_size >= var.min_size
    error_message = "The maximum size must be greater than or equal to the minimum size."
  }
}

variable "desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
  validation {
    condition     = var.desired_size >= var.min_size && var.desired_size <= var.max_size
    error_message = "The desired size must be between the minimum and maximum size."
  }
}

variable "ami_type" {
  description = "AMI type for the node group (e.g., AL2 or Ubuntu)"
  type        = string
  default     = "AL2"
  validation {
    condition     = contains(["AL2", "Ubuntu"], var.ami_type)
    error_message = "The AMI type must be either AL2 or Ubuntu."
  }
}

variable "release_version" {
  description = "EKS optimized AMI release version"
  type        = string
}

variable "eks_version" {
  description = "The EKS Kubernetes version"
  type        = string
}

variable "capacity_type" {
  description = "Capacity type for node group (OnDemand or Spot)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "The capacity type must be either ON_DEMAND or SPOT."
  }
}

variable "disk_size" {
  description = "Disk size for the node group (in GB)"
  type        = number
  default     = 20
  validation {
    condition     = var.disk_size >= 20
    error_message = "The disk size must be at least 20 GB."
  }
}

variable "launch_template" {
  description = "Whether to use a launch template for the node group"
  type        = bool
  default     = false
}

variable "launch_template_id" {
  description = "ID of the EC2 launch template (required if launch_template is true)"
  type        = string
  default     = ""
}

variable "launch_template_version" {
  description = "Version of the EC2 launch template (required if launch_template is true)"
  type        = string
  default     = ""
}

variable "remote_access_enabled" {
  description = "Whether to enable SSH access to the nodes"
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "Name of the SSH key for remote access (required if remote_access_enabled is true)"
  type        = string
  default     = ""
}

variable "ssh_security_group_ids" {
  description = "Security group IDs for SSH access (required if remote_access_enabled is true)"
  type        = list(string)
  default     = []
}

variable "taints" {
  description = "Taints to apply to the node group"
  type        = list(map(string))
  default     = []
}

variable "update_config_enabled" {
  description = "Whether to enable custom update configurations"
  type        = bool
  default     = false
}

variable "max_unavailable_percentage" {
  description = "Max unavailable percentage for the update configuration"
  type        = number
  default     = 25
}

variable "max_unavailable" {
  description = "Max unavailable for the update configuration"
  type        = number
  default     = 1
}

variable "timeouts" {
  description = "Custom timeouts for the EKS node group"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "Flag to indicate whether to create the resources"
  type        = bool
  default     = true
}

variable "create_schedule" {
  description = "Flag to indicate whether to create the autoscaling schedule"
  type        = bool
  default     = false
}

variable "schedules" {
  description = "A map of autoscaling schedule configurations"
  type = map(object({
    min_size     = number
    max_size     = number
    desired_size = number
    start_time   = string
    end_time     = string
    time_zone    = string
    recurrence   = string
  }))
  default = {}
}




# Variables for security group



# The ID of the VPC where your EKS nodes and security group should reside
variable "vpc_id" {
  description = "The VPC ID where the security group will be created."
  type        = string
}

# CIDR blocks allowed for SSH access (e.g., your office IP or 0.0.0.0/0)
variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access to the EKS nodes. Use more restrictive CIDR blocks for better security (e.g., your office IP or a VPN)."
  type        = list(string)
  default     = ["10.0.10.0/24"] # Default to allow from anywhere, but this should be restricted in production.

  # Validation rule to ensure the provided CIDR blocks are not too broad (e.g., 0.0.0.0/0 for SSH is not recommended)
  validation {
    condition     = alltrue([for cidr in var.ssh_cidr_blocks : cidr != "0.0.0.0/0"])
    error_message = "Allowing SSH from 0.0.0.0/0 is not secure. Please restrict it to trusted IPs (e.g., your office IP or a VPN)."
  }
}


### ssh_cidr_blocks = ["192.168.1.0/24"]  # Restrict SSH to your office IP range
