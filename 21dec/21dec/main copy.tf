# ##########################
# # IAM Role for EKS Cluster
# ##########################
# resource "aws_iam_role" "eks_cluster_role" {
#   for_each = var.eks_clusters

#   name = join("-", [each.value.cluster_name, "eks", "cluster", "role"])

#   assume_role_policy = jsonencode({
#     Version = var.iam_policy_version,
#     Statement = [
#       {
#         Action    = "sts:AssumeRole",
#         Effect    = "Allow",
#         Principal = { Service = "eks.amazonaws.com" }
#       }
#     ]
#   })

#   tags = merge(
#     { terraform-aws-modules = "eks" },
#     each.value.tags
#   )
# }

# ##########################
# # Attach Policies to IAM Role
# ##########################
# resource "aws_iam_role_policy_attachment" "eks_additional_policies" {
#   for_each = toset([
#     "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
#     "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
#     "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   ])

#   role       = aws_iam_role.eks_cluster_role[each.key].name
#   policy_arn = each.value
# }



# data "aws_partition" "current" {}

# data "aws_caller_identity" "current" {}

# data "aws_iam_session_context" "current" {
#   arn = try(data.aws_caller_identity.current.arn, "")
# }




# ##########################
# # EKS Cluster Configuration
# ##########################
# resource "aws_eks_cluster" "eks_cluster" { # Changed name to eks_cluster
#   for_each = var.eks_clusters

#   name                          = each.value.cluster_name
#   role_arn                      = aws_iam_role.eks_cluster_role[each.key].arn
#   version                       = each.value.cluster_version
#   enabled_cluster_log_types     = each.value.cluster_enabled_log_types
#   bootstrap_self_managed_addons = each.value.bootstrap_self_managed_addons

#   access_config {
#     authentication_mode = each.value.authentication_mode

#     bootstrap_cluster_creator_admin_permissions = try(each.value.bootstrap_cluster_creator_admin_permissions, false)
#   }

#   vpc_config {
#     security_group_ids      = aws_security_group.eks_sg_dynamic
#     endpoint_private_access = each.value.cluster_endpoint_private_access
#     endpoint_public_access  = each.value.cluster_endpoint_public_access
#     public_access_cidrs     = each.value.cluster_endpoint_public_access_cidrs
#     subnet_ids              = each.value.subnet_ids
#   }

#   kubernetes_network_config {
#     ip_family         = each.value.cluster_ip_family
#     service_ipv4_cidr = each.value.cluster_service_ipv4_cidr
#     service_ipv6_cidr = each.value.cluster_service_ipv6_cidr
#   }

#   # # KMS Encryption (Optional)
#   # encryption_config {
#   #   provider {
#   #     key_arn = each.value.kms_key_arn
#   #   }
#   #   resources = ["secrets"]
#   # }

#   # Upgrade Policy
#   upgrade_policy {
#     support_type = each.value.upgrade_policy_support_type # Can be "STANDARD" or "EXTENDED"
#   }

#   # Zonal Shift Configuration
#   zonal_shift_config {
#     enabled = each.value.zonal_shift_config_enabled # Can be true or false
#   }

#   tags = merge(
#     { terraform-aws-modules = "eks" },
#     each.value.tags
#   )

#   timeouts {
#     create = try(each.value.cluster_timeouts_create, null)
#     update = try(each.value.cluster_timeouts_update, null)
#     delete = try(each.value.cluster_timeouts_delete, null)
#   }

#   depends_on = [aws_iam_role.eks_cluster_role]

#   #   lifecycle {
#   #     ignore_changes = []
#   #   }
# }

# #############################################################################################
# # Define local variables for security group rules
# data "aws_vpc" "selected" {
#   id = var.vpc_id
# }

# locals {
#   # Automatically using the VPC CIDR block for internal communication
#   vpc_cidr = data.aws_vpc.selected.cidr_block

#   # Security group rules
#   ingress_rules = [
#     { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [local.vpc_cidr] }, # Control plane to worker nodes (VPC CIDR)
#     { from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = [local.vpc_cidr] }, # Worker to worker communication (VPC CIDR)
#     #{ from_port = 30000, to_port = 32767, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }, # NodePort access (optional, could be restricted)
#   ]
#   egress_rules = [
#     { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [local.vpc_cidr] }, # Worker to control plane (VPC CIDR)
#     #{ from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }     # Allow all outbound traffic (optional)
#   ]
# }

# resource "aws_security_group" "eks_sg_dynamic" {
#   for_each = var.eks_clusters # This will create a security group for each EKS cluster

#   name        = "${each.value.cluster_name}-ekssg" # Use cluster name from eks_clusters variable
#   description = "Security group for EKS cluster"
#   vpc_id      = var.vpc_id

#   # Dynamically adding ingress rules
#   dynamic "ingress" {
#     for_each = local.ingress_rules
#     content {
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#       #security_groups = ingress.value.security_groups
#     }
#   }

#   # Dynamically adding egress rules
#   dynamic "egress" {
#     for_each = local.egress_rules
#     content {
#       from_port   = egress.value.from_port
#       to_port     = egress.value.to_port
#       protocol    = egress.value.protocol
#       cidr_blocks = egress.value.cidr_blocks
#     }
#   }
# }


