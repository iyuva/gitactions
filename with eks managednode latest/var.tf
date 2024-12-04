variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "enabled_log_types" {
  description = "List of enabled log types for the cluster"
  type        = list(string)
}

variable "bootstrap_addons" {
  description = "List of EKS cluster bootstrap addons"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for EKS resources"
  type        = string
}

variable "security_group_protocol" {
  description = "Protocol for security group"
  type        = string
  default     = "tcp"
}

variable "security_group_from_port" {
  description = "Starting port for security group rule"
  type        = number
  default     = 443
}

variable "security_group_to_port" {
  description = "Ending port for security group rule"
  type        = number
  default     = 443
}

variable "security_group_type" {
  description = "Security group rule type"
  type        = string
  default     = "ingress"
}

variable "security_group_description" {
  description = "Security group rule description"
  type        = string
  default     = "Allow access to EKS control plane"
}

variable "security_group_cidr_blocks" {
  description = "CIDR blocks for security group"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
}

variable "node_group_ami_type" {
  description = "AMI type for EKS node group"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_group_desired_size" {
  description = "Desired size for the EKS node group"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum size for the EKS node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum size for the EKS node group"
  type        = number
  default     = 3
}

variable "node_group_instance_types" {
  description = "List of instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "default_tags" {
  description = "Default tags for AWS resources"
  type        = map(string)
  default = {
    "Environment" = "production"
  }
}

variable "cluster_timeouts" {
  description = "Timeouts for the cluster lifecycle"
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
