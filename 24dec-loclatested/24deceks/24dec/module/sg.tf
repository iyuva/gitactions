# # Variables for security group rules
# variable "ingress_rules" {
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
#   default = [
#     # Allow all TCP traffic (usually for general inbound communication like application access)
#     {
#       from_port   = 0
#       to_port     = 65535
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#     # Allow HTTPS (port 443) for secure web traffic from anywhere
#     {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#     # Allow SSH (port 22) for administrative access to the EKS nodes (caution: you may want to restrict this)
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"] # You may want to restrict this to a specific IP or range for better security
#     }
#   ]
# }

# variable "egress_rules" {
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
#   default = [
#     # Allow all outbound TCP traffic (to reach external services or resources)
#     {
#       from_port   = 0
#       to_port     = 65535
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"] # Allows the EKS cluster to make outbound connections to the internet
#     }
#   ]
# }

# # Create a Security Group for the EKS Cluster
# resource "aws_security_group" "eks_sg" {
#   name_prefix = "eks-cluster-sg-"
#   description = "EKS Cluster Security Group"
#   vpc_id      = var.vpc_id # Replace with your VPC ID

#   # Dynamic block to add ingress rules
#   dynamic "ingress" {
#     for_each = var.ingress_rules
#     content {
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#     }
#   }

#   # Dynamic block to add egress rules
#   dynamic "egress" {
#     for_each = var.egress_rules
#     content {
#       from_port   = egress.value.from_port
#       to_port     = egress.value.to_port
#       protocol    = egress.value.protocol
#       cidr_blocks = egress.value.cidr_blocks
#     }
#   }

#   tags = {
#     Name = "eks-cluster-sg"
#   }
# }

# output "eks_sg_id" {
#   value = aws_security_group.eks_sg.id
# }
