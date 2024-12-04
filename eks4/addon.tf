# # Terraform Configuration
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
#   required_version = ">= 1.3.0"
# }

# provider "aws" {
#   region = "us-east-1" # Replace with your AWS region
# }

# # Variables
# variable "cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
#   default     = "my-eks-cluster" # Replace with your cluster name
# }

# variable "addons" {
#   description = "List of addons with their versions"
#   type = map(object({
#     addon_name    = string
#     addon_version = string
#     policy_actions = list(string) # IAM actions specific to each addon
#   }))
#   default = {
#     vpc-cni = {
#       addon_name    = "vpc-cni"
#       addon_version = "v1.14.0-eksbuild.2"
#       policy_actions = [
#         "ec2:Describe*",
#         "ec2:CreateNetworkInterface",
#         "ec2:DeleteNetworkInterface",
#         "ec2:AttachNetworkInterface",
#         "ec2:DetachNetworkInterface"
#       ]
#     }
#     coredns = {
#       addon_name    = "coredns"
#       addon_version = "v1.8.7-eksbuild.1"
#       policy_actions = []
#     }
#     kube-proxy = {
#       addon_name    = "kube-proxy"
#       addon_version = "v1.24.1-eksbuild.2"
#       policy_actions = []
#     }
#   }
# }

# # IAM Role and Policies for Each Addon
# resource "aws_iam_policy" "addon_policies" {
#   for_each = var.addons

#   name        = "${each.value.addon_name}-policy"
#   description = "Policy for ${each.value.addon_name} addon"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = each.value.policy_actions
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role" "addon_roles" {
#   for_each = var.addons

#   name               = "${each.value.addon_name}-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect    = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "addon_policy_attachments" {
#   for_each = var.addons

#   role       = aws_iam_role.addon_roles[each.key].name
#   policy_arn = aws_iam_policy.addon_policies[each.key].arn
# }

# # EKS Addons
# resource "aws_eks_addon" "addons" {
#   for_each = var.addons

#   cluster_name              = var.cluster_name
#   addon_name                = each.value.addon_name
#   addon_version             = each.value.addon_version
#   resolve_conflicts         = "OVERWRITE"
#   service_account_role_arn  = aws_iam_role.addon_roles[each.key].arn
# }

# # Outputs
# output "eks_addon_status" {
#   value = {
#     for k, v in aws_eks_addon.addons :
#     k => v.status
#   }
# }

# output "eks_addon_iam_roles" {
#   value = {
#     for k, v in aws_iam_role.addon_roles :
#     k => v.arn
#   }
# }
