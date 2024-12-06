# # EKS Cluster Configuration
# cluster_name    = "my-cluster"                       # Name of the EKS cluster
# node_group_name = "my-node-group"                    # Name of the EKS node group
# subnet_ids      = ["subnet-abc123", "subnet-def456"] # List of subnet IDs for the node group
# vpc_id          = "vpc-123abc456"                    # VPC ID for the security group
# ami_type        = "AL2_x86_64"                       # AMI Type for the nodes (AL2 or Ubuntu)
# release_version = "1.24"                             # EKS optimized AMI release version
# eks_version     = "1.30"                             # Kubernetes version for the node group
# capacity_type   = "ON_DEMAND"                        # Capacity type (ON_DEMAND or SPOT)
# disk_size       = 20                                 # EBS volume size in GB for nodes
# min_size        = 2                                  # Minimum number of nodes
# max_size        = 5                                  # Maximum number of nodes
# desired_size    = 3                                  # Desired number of nodes

# # Launch Template (Optional)
# launch_template         = true          # Whether to use a launch template
# launch_template_id      = "lt-12345abc" # Launch template ID
# launch_template_version = "1"           # Launch template version

# # Remote Access (Optional)
# remote_access_enabled  = true             # Whether to enable remote access (SSH)
# ssh_key_name           = "my-ssh-key"     # SSH key name for EC2 instances
# ssh_security_group_ids = ["sg-123abc456"] # Security group IDs for SSH access

# # Taints (Optional)
# taints = [
#   {
#     key    = "key1"
#     value  = "value1"
#     effect = "NO_SCHEDULE"
#   }
# ]

# # Update Configuration (Optional)
# update_config_enabled      = true # Whether to enable custom update configuration
# max_unavailable_percentage = 10   # Maximum percentage of nodes that can be unavailable during an update
# max_unavailable            = 1    # Maximum number of nodes that can be unavailable during an update

# # Timeouts Configuration (Optional)
# timeouts = {
#   create = "30m"
#   update = "30m"
#   delete = "30m"
# }

# # Security Group Configuration
# ssh_cidr_blocks = ["0.0.0.0/0"] # CIDR blocks allowed for SSH access

# # Autoscaling Schedule (Optional)
# create_schedule = true # Whether to create autoscaling schedules
# create          = true # Whether to enable autoscaling
# schedules = {
#   "morning-scaling" = {
#     min_size     = 3
#     max_size     = 5
#     desired_size = 4
#     start_time   = "2024-12-06T08:00:00Z"
#     end_time     = "2024-12-06T18:00:00Z"
#     time_zone    = "UTC"
#     recurrence   = "0 8-18 * * *" # Cron schedule for scaling between 8am to 6pm UTC
#   }
# }

# # Tags
# tags = {
#   "Environment" = "Production"
#   "Owner"       = "Team A"
# }
