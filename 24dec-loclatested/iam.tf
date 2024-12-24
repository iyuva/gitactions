




# provider "aws" {
#   region = "us-east-1"  # Change to your desired AWS region
# }

# Data blocks for partition and caller identity
data "aws_caller_identity" "current" {}

# Define the variable for EKS cluster name
variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "yuva-cluster" # Default value can be overridden by the user
}
variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1" # Default region
}


# Create the EKS IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.eks_cluster_name}-cluster-role" #"eks-cluster-role"  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Create a customer-managed policy with both Allow and Deny
resource "aws_iam_policy" "allow_deny_policy" {
  name        = "CustomAllowDenyPolicy"
  description = "A policy that allows and denies specific EKS actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow specific actions on EKS clusters
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups"
        ]
        Resource = "arn:aws:eks:${var.region}:*"
      },
      # Deny specific actions on specific EKS clusters and EC2 instances
      {
        Effect = "Deny"
        Action = [
          "eks:DeleteCluster",
          "eks:UpdateClusterVersion",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        # Restrict to specific EKS cluster ARN and EC2 resources
        Resource = [
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}", # Using variable for cluster name
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*",                      # Example for EC2 instance ARN
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*",                # Example for EC2 security group ARN
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/*",                        # Example for EC2 subnet ARN
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/*"                            # Example for EC2 VPC ARN
        ]
      }
    ]
  })
}

# Attach AWS Managed Policies to the IAM Role
locals {
  aws_managed_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]
}

resource "aws_iam_role_policy_attachment" "aws_managed_policies" {
  for_each = toset(local.aws_managed_policies)

  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

# Attach the Customer-Managed Policy (Allow and Deny) to the IAM Role
resource "aws_iam_role_policy_attachment" "customer_managed_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.allow_deny_policy.arn
}

