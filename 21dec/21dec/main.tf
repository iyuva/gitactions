# Data Sources
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = try(data.aws_caller_identity.current.arn, "")
}

# data "aws_vpc" "selected" {
#   id = var.vpc_id
# }



############### 
### IAM 
###############


# AWS Managed Policies (you can add more AWS managed policies as needed)
locals {
  aws_managed_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    # "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",  # S3 read-only
    # "arn:aws:iam::aws:policy/SecretsManagerReadWrite", # SecretsManager
    # "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"  # EC2 Read-only
  ]
}

# Customer Managed Policies
locals {
  customer_managed_policies = [
    # Custom policy for Secrets Manager (you can change permissions as needed)
    {
      name        = "CustomSecretsManagerPolicy"
      description = "Custom policy to access Secrets Manager"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "secretsmanager:GetSecretValue",
              "secretsmanager:ListSecrets"
            ]
            Resource = "*"
          }
        ]
      })
    },

    # Custom policy for S3 (you can change permissions as needed)
    # {
    #   name        = "CustomS3Policy"
    #   description = "Custom policy for S3 read and write"
    #   policy = jsonencode({
    #     Version = "2012-10-17"
    #     Statement = [
    #       {
    #         Effect = "Allow"
    #         Action = [
    #           "s3:ListBucket",
    #           "s3:GetObject",
    #           "s3:PutObject"
    #         ]
    #         Resource = [
    #           "arn:aws:s3:::my-bucket",
    #           "arn:aws:s3:::my-bucket/*"
    #         ]
    #       }
    #     ]
    #   })
    # },

    # Custom policy for EKS (you can change permissions as needed)
    {
      name        = "CustomEKSPolicy"
      description = "Custom policy to manage EKS resources"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "eks:DescribeCluster",
              "eks:ListClusters",
              "eks:DescribeNodegroup",
              "eks:ListNodegroups"
            ]
            Resource = "*"
          }
        ]
      })
    }
  ]
}

# Combine all the policies into one list for dynamic attachment
locals {
  all_policies = concat(local.aws_managed_policies, [for policy in local.customer_managed_policies : policy.name])
}

# Create IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create Customer Managed Policies (Secrets Manager, S3, EKS, etc.)
resource "aws_iam_policy" "customer_managed_policies" {
  for_each = { for policy in local.customer_managed_policies : policy.name => policy }

  name        = each.value.name
  description = each.value.description
  policy      = each.value.policy
}

# Attach the AWS Managed Policies to the EKS Role
resource "aws_iam_role_policy_attachment" "aws_managed_policies_attachment" {
  for_each   = toset(local.aws_managed_policies) # Iterate over AWS managed policies
  policy_arn = each.value                        # Attach each AWS managed policy
  role       = aws_iam_role.eks_cluster_role.name
}

# Attach the Customer Managed Policies to the EKS Role
resource "aws_iam_role_policy_attachment" "customer_managed_policies_attachment" {
  for_each   = aws_iam_policy.customer_managed_policies
  policy_arn = aws_iam_policy.customer_managed_policies[each.key].arn # Correct ARN reference
  role       = aws_iam_role.eks_cluster_role.name
  depends_on = [aws_iam_policy.customer_managed_policies]
}

# EKS Cluster Configuration
resource "aws_eks_cluster" "eks_cluster" {
  for_each = var.eks_clusters

  name                          = each.value.cluster_name
  role_arn                      = aws_iam_role.eks_cluster_role.arn
  version                       = each.value.cluster_version
  enabled_cluster_log_types     = each.value.cluster_enabled_log_types
  bootstrap_self_managed_addons = each.value.bootstrap_self_managed_addons

  access_config {
    authentication_mode                         = each.value.authentication_mode
    bootstrap_cluster_creator_admin_permissions = try(each.value.bootstrap_cluster_creator_admin_permissions, false)
  }

  vpc_config {
    security_group_ids      = [for sg in aws_security_group.eks_sg_dynamic : sg.id]
    endpoint_private_access = each.value.cluster_endpoint_private_access
    endpoint_public_access  = each.value.cluster_endpoint_public_access
    public_access_cidrs     = each.value.cluster_endpoint_public_access_cidrs
    subnet_ids              = each.value.subnet_ids
  }

  kubernetes_network_config {
    ip_family         = each.value.cluster_ip_family
    service_ipv4_cidr = each.value.cluster_service_ipv4_cidr
    #service_ipv6_cidr = each.value.cluster_service_ipv6_cidr
  }

  upgrade_policy {
    support_type = each.value.upgrade_policy_support_type
  }

  zonal_shift_config {
    enabled = each.value.zonal_shift_config_enabled
  }

  tags = merge(
    { terraform-aws-modules = "eks" },
    each.value.tags
  )

  timeouts {
    create = try(each.value.cluster_timeouts_create, "30m") # Default to 30 minutes
    update = try(each.value.cluster_timeouts_update, "30m") # Default to 30 minutes
    delete = try(each.value.cluster_timeouts_delete, "30m") # Default to 30 minutes
  }

  depends_on = [aws_iam_role.eks_cluster_role]
}

# # Security Group for EKS Cluster



# Fetch VPC CIDR dynamically using the VPC ID
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Define local variables for security group rules
locals {
  # Automatically using the VPC CIDR block for internal communication
  vpc_cidr = data.aws_vpc.selected.cidr_block

  # Security group rules
  ingress_rules = [
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [local.vpc_cidr] },  # Control plane to worker nodes (VPC CIDR)
    { from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = [local.vpc_cidr] },  # Worker to worker communication (VPC CIDR)
    { from_port = 30000, to_port = 32767, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }, # NodePort access (optional, could be restricted)
  ]

  egress_rules = [
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [local.vpc_cidr] }, # Worker to control plane (VPC CIDR)
    { from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }     # Allow all outbound traffic (optional)
  ]
}

# Create the security group resource
resource "aws_security_group" "eks_sg_dynamic" {
  name        = "${var.cluster_name}-ekssg" # Security group name based on cluster name
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  # Dynamically adding ingress rules
  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Dynamically adding egress rules
  dynamic "egress" {
    for_each = local.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}



