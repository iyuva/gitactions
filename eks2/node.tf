# Node Group for each EKS cluster
resource "aws_eks_node_group" "this" {
  for_each = var.clusters

  cluster_name    = aws_eks_cluster.this[each.key].name
  node_group_name = "${each.value.cluster_name}-${var.region}-${var.environment}-node-group"
  node_role       = aws_iam_role.this[each.key].arn
  subnet_ids      = var.subnet_ids

  # Specify the instance type for the node group
  instance_types = each.value.instance_types != null ? each.value.instance_types : [var.node_instance_type]

  scaling_config {
    desired_size = each.value.node_group_desired_size != null ? each.value.node_group_desired_size : var.node_group_desired_size
    min_size     = each.value.node_group_min_size != null ? each.value.node_group_min_size : var.node_group_min_size
    max_size     = each.value.node_group_max_size != null ? each.value.node_group_max_size : var.node_group_max_size
  }

  # Disk size for the node group
  disk_size = each.value.node_group_disk_size != null ? each.value.node_group_disk_size : var.node_group_disk_size

  # Enable or disable AMI updates (if you are using managed AMI updates)
  update_config {
    max_unavailable = var.node_group_max_unavailable
  }

  # Remote access (optional, can be customized for SSH or other access)
  remote_access {
    ec2_ssh_key = var.ec2_ssh_key
    source_security_group_ids = compact(distinct(concat(var.node_security_group_ids, [aws_security_group.this.id])))
  }

  # Optional: Taints and Labels for specific workloads
  taints = each.value.node_group_taints != null ? each.value.node_group_taints : []

  labels = merge(
    each.value.node_group_labels != null ? each.value.node_group_labels : {},
    { "eks-node-group" = "${each.value.cluster_name}-${var.region}-${var.environment}" }
  )

  # Spot instances configuration
  instance_types = each.value.use_spot_instances ? [each.value.spot_instance_type] : [var.node_instance_type]

  # AMI type, default to AL2 (Amazon Linux 2)
  ami_type = each.value.node_group_ami_type != null ? each.value.node_group_ami_type : "AL2_x86_64"

  # Node Group Tags for management
  tags = merge(
    { "terraform-aws-modules" = "eks-node-group" },
    var.tags,
    var.node_group_tags,
    { "NodeGroup" = "${each.value.cluster_name}-${var.region}-${var.environment}" }
  )

  # CloudWatch Logs Configuration
  resources {
    cloudwatch_logs_group = aws_cloudwatch_log_group.this[each.key].name
  }

  # Timeouts for create, update, and delete operations
  timeouts {
    create = try(var.node_group_timeouts.create, null)
    update = try(var.node_group_timeouts.update, null)
    delete = try(var.node_group_timeouts.delete, null)
  }

  # Auto Scaling
  enable_auto_scaling = each.value.auto_scaling_enabled != null ? each.value.auto_scaling_enabled : true
}

# Node Security Group Tagging
resource "aws_ec2_tag" "node_group_security_group" {
  for_each = var.clusters

  resource_id = aws_eks_node_group.this[each.key].resources[0].security_group_ids[0]
  key         = each.key
  value       = each.value.cluster_name # Customize as needed
}

# Optional: Custom Launch Template for Node Group
resource "aws_launch_template" "this" {
  for_each = var.clusters

  name_prefix   = "${each.value.cluster_name}-node-group"
  image_id      = var.custom_ami_id != null ? var.custom_ami_id : null
  instance_type = var.node_instance_type

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    { "terraform-aws-modules" = "eks-node-group-launch-template" },
    var.tags,
    { "NodeGroup" = "${each.value.cluster_name}-${var.region}-${var.environment}" }
  )
}






######################     var

variable "clusters" {
  description = "Map of EKS cluster configurations"
  type = map(object({
    cluster_name              = string
    instance_types            = list(string)
    node_group_desired_size   = number
    node_group_min_size       = number
    node_group_max_size       = number
    node_group_disk_size      = number
    node_group_taints         = list(object({ key = string, value = string, effect = string }))
    node_group_labels         = map(string)
    enable_cluster_encryption = bool
    node_group_ami_type       = string
    use_spot_instances        = bool
    spot_instance_type        = string
    auto_scaling_enabled      = bool
  }))
}

variable "node_instance_type" {
  description = "Default EC2 instance type for nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_group_desired_size" {
  description = "Desired size of the node group"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum size of the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum size of the node group"
  type        = number
  default     = 5
}

variable "node_group_disk_size" {
  description = "Disk size for the node group instances"
  type        = number
  default     = 20
}

variable "node_security_group_ids" {
  description = "List of additional security group IDs for the nodes"
  type        = list(string)
  default     = []
}

variable "ec2_ssh_key" {
  description = "SSH Key Pair for EC2 instances"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "node_group_tags" {
  description = "Tags to apply to node groups"
  type        = map(string)
  default     = {}
}



#############  tfvars 

# Cluster Configuration
clusters = {
  cluster1 = {
    cluster_name              = "cluster1"
    instance_types            = ["t3.medium", "t3.large"]
    node_group_desired_size   = 3
    node_group_min_size       = 2
    node_group_max_size       = 5
    node_group_disk_size      = 20
    node_group_taints         = [
      { key = "key1", value = "value1", effect = "NoSchedule" },
      { key = "key2", value = "value2", effect = "PreferNoSchedule" }
    ]
    node_group_labels         = {
      "environment" = "production"
      "role"         = "worker"
    }
    enable_cluster_encryption = true
    node_group_ami_type       = "AL2_x86_64"
    use_spot_instances        = true
    spot_instance_type        = "t3.medium"
    auto_scaling_enabled      = true
  }
  
  cluster2 = {
    cluster_name              = "cluster2"
    instance_types            = ["t3.medium"]
    node_group_desired_size   = 2
    node_group_min_size       = 1
    node_group_max_size       = 3
    node_group_disk_size      = 30
    node_group_taints         = []
    node_group_labels         = {
      "environment" = "staging"
      "role"         = "worker"
    }
    enable_cluster_encryption = false
    node_group_ami_type       = "AL2_x86_64"
    use_spot_instances        = false
    spot_instance_type        = "t3.medium"
    auto_scaling_enabled      = true
  }
}

# Default EC2 Instance Type for Node Groups
node_instance_type = "t3.medium"

# Default Node Group Size
node_group_desired_size = 3
node_group_min_size     = 2
node_group_max_size     = 5

# Node Group Disk Size in GB
node_group_disk_size = 20

# List of additional Security Group IDs for the Node Groups
node_security_group_ids = [
  "sg-xxxxxxxx",
  "sg-yyyyyyyy"
]

# SSH Key Pair for EC2 Instances (if remote access is enabled)
ec2_ssh_key = "your-ec2-ssh-key"

# Tags for all resources
tags = {
  "Owner"       = "TeamA"
  "Project"     = "ProjectX"
  "Environment" = "production"
}

# Node Group Specific Tags (for node-level management)
node_group_tags = {
  "ClusterName" = "Cluster1"
  "NodeRole"    = "worker"
}

# CloudWatch Log Retention Period (in days)
cloudwatch_log_group_retention_in_days = 30

# CloudWatch Log Group KMS Key ID (for encryption)
cloudwatch_log_group_kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# CloudWatch Log Group Class
cloudwatch_log_group_class = "STANDARD"

# IAM Role Configuration
iam_role_use_name_prefix = true
iam_role_path             = "/aws/eks/"
iam_role_description      = "EKS Node Group Role"
iam_role_permissions_boundary = "arn:aws:iam::aws:policy/AdministratorAccess"

# Cluster Encryption Configuration (if encryption is enabled)
create_kms_key       = true
cluster_encryption_policy_use_name_prefix = true
cluster_encryption_policy_description   = "EKS Cluster Encryption Policy"
cluster_encryption_policy_path          = "/aws/eks/encryption"

# Timeouts for Node Group Operations
node_group_timeouts = {
  create = "30m"
  update = "20m"
  delete = "15m"
}

# Optional: Set if using a custom AMI ID
custom_ami_id = null

# Auto-scaling Configuration
node_group_max_unavailable = 1



