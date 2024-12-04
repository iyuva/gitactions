# # Defining the AWS EKS cluster resource using a for_each loop to create multiple clusters.
# # Each cluster is identified by the unique names passed in the 'var.cluster_names' map.
# resource "aws_eks_cluster" "eks_cluster" {
#   # The for_each expression creates a cluster for each entry in the 'cluster_names' map.
#   for_each = var.cluster_names

#   # Name of the EKS cluster. Each key from the 'cluster_names' map becomes the name.
#   name = each.key

#   # ARN of the IAM role associated with the EKS cluster. This role grants permissions to the EKS service.
#   role_arn = aws_iam_role.eks_role.arn

#   # Version of Kubernetes to be used for the EKS cluster. Set from the variable 'eks_version'.
#   version = var.eks_version

#   # Enabling specific logging types for the cluster, passed via the 'enabled_log_types' variable.
#   enabled_cluster_log_types = var.enabled_log_types

#   # Bootstrap options for self-managed add-ons, such as Helm charts or other integrations.
#   bootstrap_self_managed_addons = var.bootstrap_addons

#   # Configuring access settings for the EKS cluster.
#   access_config {
#     # Authentication mode for the cluster, specifying how users authenticate to the cluster.
#     authentication_mode = var.authentication_mode

#     # Determines if cluster creator should have admin permissions.
#     bootstrap_cluster_creator_admin_permissions = var.cluster_creator_permissions
#   }

#   # Configuring the VPC settings for the EKS cluster, such as subnets, security groups, and access controls.
#   vpc_config {
#     # List of security group IDs to associate with the EKS cluster.
#     security_group_ids = var.security_group_ids

#     # List of subnet IDs where the EKS cluster should be deployed.
#     subnet_ids = var.subnet_ids

#     # Enabling private access to the cluster's API server.
#     endpoint_private_access = var.endpoint_private_access

#     # Enabling public access to the cluster's API server.
#     endpoint_public_access = var.endpoint_public_access

#     # CIDR blocks that can access the API server if public access is enabled.
#     public_access_cidrs = var.public_access_cidrs
#   }

#   # Dynamically configure Kubernetes network settings, only if the 'kubernetes_network_config' variable is provided.
#   dynamic "kubernetes_network_config" {
#     for_each = var.kubernetes_network_config != null ? [1] : []
#     content {
#       # Maximum number of pods that can be scheduled per node in the cluster.
#       max_pods_per_node = var.kubernetes_network_max_pods
#     }
#   }

#   # Dynamically configure outpost settings, only if the 'outpost_config' variable is provided.
#   dynamic "outpost_config" {
#     for_each = var.outpost_config != null ? [1] : []
#     content {
#       # ARN of the outpost in which the cluster should be deployed (for hybrid or edge use cases).
#       outpost_arn = var.outpost_arn
#     }
#   }

#   # Dynamically configure encryption settings for the cluster, only if 'encryption_config' is provided.
#   dynamic "encryption_config" {
#     for_each = var.encryption_config != null ? [1] : []
#     content {
#       provider {
#         # ARN of the KMS key used to encrypt the cluster data.
#         key_arn = var.encryption_key_arn
#       }

#       # Resources that need to be encrypted. Typically, this could be the 'secrets' or 'configmaps'.
#       resources = var.encryption_resources
#     }
#   }

#   # Dynamically configure the upgrade policy for the cluster, only if 'upgrade_policy' is provided.
#   dynamic "upgrade_policy" {
#     for_each = var.upgrade_policy != null ? [1] : []
#     content {
#       # Maximum number of EKS nodes that can be unavailable during an upgrade.
#       max_unavailable = var.max_unavailable
#     }
#   }

#   # Dynamically configure zonal shift settings, only if 'zonal_shift_config' is provided.
#   dynamic "zonal_shift_config" {
#     for_each = var.zonal_shift_config != null ? [1] : []
#     content {
#       # Enables or disables zonal shift in case of availability zone issues.
#       zone_shift_enabled = var.zonal_shift_enabled
#     }
#   }

#   # Tags are used for resource identification and management. The 'ClusterName' tag is unique for each cluster.
#   tags = merge(
#     var.default_tags, # Default tags passed via the 'default_tags' variable.
#     {
#       "ClusterName" = each.key # Unique cluster name tag for each EKS cluster.
#     }
#   )

#   # Timeouts for the cluster creation, update, and deletion operations to ensure Terraform doesn't time out during long processes.
#   timeouts {
#     # Time to wait for the EKS cluster creation to complete (default 30 minutes).
#     create = try(var.cluster_timeouts.create, "30m")

#     # Time to wait for the EKS cluster update to complete (default 20 minutes).
#     update = try(var.cluster_timeouts.update, "20m")

#     # Time to wait for the EKS cluster deletion to complete (default 30 minutes).
#     delete = try(var.cluster_timeouts.delete, "30m")
#   }

#   # Explicitly define dependencies to ensure IAM role is created before the EKS cluster.
#   depends_on = [
#     aws_iam_role.eks_role # This ensures the IAM role is available before the cluster is created.
#   ]

#   # Lifecycle block to prevent Terraform from making changes to certain parts of the configuration.
#   lifecycle {
#     # Ignore changes to dynamic configuration blocks, as some resources may be updated manually.
#     ignore_changes = [
#       "kubernetes_network_config",
#       "outpost_config",
#       "encryption_config",
#       "upgrade_policy",
#       "zonal_shift_config"
#     ]
#   }
#   #   lifecycle {
#   #     ignore_changes = [
#   #       access_config[0].bootstrap_cluster_creator_admin_permissions
#   #     ]
#   #   }
#   # }
# }



# #######################  
# ###IAM 
# #######################  

# # IAM Role for EKS Cluster (Control Plane)

# resource "aws_iam_role" "eks_role" {
#   name = "eks-cluster-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Effect = "Allow"
#         Sid    = ""
#       },
#     ]
#   })

#   tags = {
#     Name = "eks-cluster-role"
#   }
# }

# #IAM Policies for EKS Cluster

# resource "aws_iam_policy" "eks_policy" {
#   name        = "eks-cluster-policy"
#   description = "EKS Cluster policy for managing EKS control plane"

#   # The policy document for the EKS cluster role, granting the necessary EKS permissions
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "eks:CreateCluster",
#           "eks:DescribeCluster",
#           "eks:UpdateClusterVersion",
#           "eks:UpdateClusterConfig",
#           "eks:DeleteCluster"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#       {
#         Action = [
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVpcs",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:CreateSecurityGroup",
#           "ec2:ModifyInstanceAttribute"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#       {
#         Action = [
#           "iam:PassRole"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       }
#     ]
#   })
# }

# # IAM Role Policy Attachment for EKS Cluster

# resource "aws_iam_role_policy_attachment" "eks_cluster_attachment" {
#   policy_arn = aws_iam_policy.eks_policy.arn
#   role       = aws_iam_role.eks_role.name
# }



