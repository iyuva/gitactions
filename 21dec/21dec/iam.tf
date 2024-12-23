# provider "aws" {
#   region = "var.region"
# }

# data "aws_partition" "current" {}

# data "aws_caller_identity" "current" {}

# data "aws_iam_session_context" "current" {
#   arn = try(data.aws_caller_identity.current.arn, "")
# }

# # Create the IAM policy for EKS Cluster
# resource "aws_iam_policy" "eks_cluster_policy" {
#   name        = "eks-cluster-policy"
#   description = "IAM policy for EKS Cluster access"
#   policy      = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "eks:DescribeCluster",
#           "eks:ListClusters",
#           "eks:ListUpdates",
#           "eks:DescribeUpdate",
#           "eks:DescribeNodegroup",
#           "eks:ListNodegroups"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect   = "Allow"
#         Action   = [
#           "ec2:DescribeInstances",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVpcs"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Create IAM Role for EKS Cluster
# resource "aws_iam_role" "eks_cluster_role" {
#   name               = "eks-cluster-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Action   = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Attach the EKS policy to the IAM role
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
#   policy_arn = aws_iam_policy.eks_cluster_policy.arn
#   role       = aws_iam_role.eks_cluster_role.name
# }





# ########################################## 2nd type ##########
# # Provider configuration
# provider "aws" {
#   region = var.region  # Use the region variable
# }

# # Data block for partition and caller identity
# data "aws_partition" "current" {}

# data "aws_caller_identity" "current" {}

# data "aws_iam_session_context" "current" {
#   arn = try(data.aws_caller_identity.current.arn, "")
# }

# # Variable for region
# variable "region" {
#   description = "AWS region"
#   type        = string
#   default     = "us-east-1"
# }


# ##
# # Managed Policies ARNs
# locals {
#   managed_policies = [
#     "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
#     "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
#     "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   ]
# }


# # Create the IAM policy for EKS Cluster
# resource "aws_iam_policy" "eks_cluster_policy" {
#   name        = "eks-cluster-policy"
#   description = "IAM policy for EKS Cluster access"
#   policy      = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "eks:DescribeCluster",
#           "eks:ListClusters",
#           "eks:ListUpdates",
#           "eks:DescribeUpdate",
#           "eks:DescribeNodegroup",
#           "eks:ListNodegroups"
#         ]
#         Resource = "*"  
#       },
#       {
#         Effect   = "Allow"
#         Action   = [
#           "ec2:DescribeInstances",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVpcs"
#         ]
#         Resource = "*"  # Can be specific resources if needed
#       }
#     ]
#   })
# }

# # Create IAM Role for EKS Cluster
# resource "aws_iam_role" "eks_cluster_role" {
#   name               = "eks-cluster-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Action   = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Attach the EKS policy to the IAM role
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
#   policy_arn = aws_iam_policy.eks_cluster_policy.arn
#   role       = aws_iam_role.eks_cluster_role.name
# }

# # Attach the AWS Managed Policies to the IAM role
# resource "aws_iam_role_policy_attachment" "aws_managed_policies_attachment" {
#   for_each = toset(local.managed_policies)  # Attach the managed policies dynamically
#   policy_arn = each.value  # Attach the ARN from the list of AWS Managed policies
#   role       = aws_iam_role.eks_cluster_role.name
# }




# #########################################################
# ### for_each logic  ###

# # Provider configuration
# provider "aws" {
#   region = var.region  # AWS region specified by the user or defaults to "us-east-1"
# }

# # Data blocks for partition and caller identity
# data "aws_partition" "current" {}
# data "aws_caller_identity" "current" {}

# # Variable for region
# variable "region" {
#   description = "AWS region"
#   type        = string
#   default     = "us-east-1"
# }

# ## Managed Policies ARNs
# locals {
#   managed_policies = [
#     "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
#     "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
#     "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   ]

#   # Future policies can be added to this list.
#   additional_policies = [
#     "arn:aws:iam::aws:policy/SomeOtherPolicy"  # Example for adding more policies
#   ]

#   # Combine both managed policies and additional policies into one list
#   all_policies = concat(local.managed_policies, local.additional_policies)
# }

# # Create the IAM policy for EKS Cluster (custom policy with least privilege)
# resource "aws_iam_policy" "eks_cluster_policy" {
#   name        = "eks-cluster-policy"
#   description = "IAM policy for EKS Cluster access"
#   policy      = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "eks:DescribeCluster",
#           "eks:ListClusters",
#           "eks:ListUpdates",
#           "eks:DescribeUpdate",
#           "eks:DescribeNodegroup",
#           "eks:ListNodegroups"
#         ]
#         Resource = "*"  # Broad scope for EKS actions; can be refined further
#       },
#       {
#         Effect   = "Allow"
#         Action   = [
#           "ec2:DescribeInstances",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVpcs"
#         ]
#         Resource = "*"  # Broad scope for EC2 actions; specify resources for tighter control
#       }
#     ]
#   })
# }

# # Create IAM Role for EKS Cluster
# resource "aws_iam_role" "eks_cluster_role" {
#   name               = "eks-cluster-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Action   = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Attach the custom EKS policy to the IAM role
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
#   policy_arn = aws_iam_policy.eks_cluster_policy.arn
#   role       = aws_iam_role.eks_cluster_role.name
# }

# # Attach AWS Managed Policies and additional policies using for_each
# resource "aws_iam_role_policy_attachment" "aws_managed_policies_attachment" {
#   for_each  = toset(local.all_policies)  # Iterate over all policies
#   policy_arn = each.value  # Attach each policy dynamically
#   role       = aws_iam_role.eks_cluster_role.name
# }


