


# # Fetch VPC CIDR dynamically using the VPC ID
# data "aws_vpc" "selected" {
#   id = var.vpc_id
# }

# # Define local variables for security group rules
# locals {
#   # Automatically using the VPC CIDR block for internal communication
#   vpc_cidr = data.aws_vpc.selected.cidr_block

#   # Security group rules
#   ingress_rules = [
#     { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [local.vpc_cidr] },  # Control plane to worker nodes (VPC CIDR)
#     { from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = [local.vpc_cidr] },  # Worker to worker communication (VPC CIDR)
#     { from_port = 30000, to_port = 32767, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }, # NodePort access (optional, could be restricted)
#   ]
#   egress_rules = [
#     { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = [local.vpc_cidr] }, # Worker to control plane (VPC CIDR)
#     { from_port = 0, to_port = 65535, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }     # Allow all outbound traffic (optional)
#   ]
# }

# # Create the security group resource
# resource "aws_security_group" "eks_sg_dynamic" {
#   name        = "${each.value.cluster_name}-ekssg" # Security group name based on cluster name
#   description = "Security group for EKS cluster"
#   vpc_id      = var.vpc_id

#   # Dynamically adding ingress rules
#   dynamic "ingress" {
#     for_each = local.ingress_rules
#     content {
#       from_port       = ingress.value.from_port
#       to_port         = ingress.value.to_port
#       protocol        = ingress.value.protocol
#       cidr_blocks     = ingress.value.cidr_blocks
#       security_groups = ingress.value.security_groups
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

# # Output the Security Group ID
# output "eks_security_group_id" {
#   value = aws_security_group.eks_sg_dynamic.id
# }




################
##OLD
################
