


# Data blocks for partition and caller identity
data "aws_caller_identity" "current" {}





# Create the EKS IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role" #"${var.cluster_name}-cluster-role" #  
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
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}", # Using variable for cluster name
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*",                  # Example for EC2 instance ARN
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*",            # Example for EC2 security group ARN
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/*",                    # Example for EC2 subnet ARN
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/*"                        # Example for EC2 VPC ARN
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




###################
# Variables for security group rules
variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    # Allow all TCP traffic (usually for general inbound communication like application access)
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    # Allow HTTPS (port 443) for secure web traffic from anywhere
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    # Allow SSH (port 22) for administrative access to the EKS nodes (caution: you may want to restrict this)
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # You may want to restrict this to a specific IP or range for better security
    }
  ]
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    # Allow all outbound TCP traffic (to reach external services or resources)
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Allows the EKS cluster to make outbound connections to the internet
    }
  ]
}

# Create a Security Group for the EKS Cluster
resource "aws_security_group" "eks_sg" {
  #name        = "dummy"
  name_prefix = "${var.cluster_name}-sg" #"eks-cluster-sg-"
  description = "EKS Cluster Security Group"
  vpc_id      = var.vpc_id # Replace with your VPC ID

  # Dynamic block to add ingress rules
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Dynamic block to add egress rules
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

output "eks_sg_id" {
  value = aws_security_group.eks_sg.id
}

###############

resource "aws_eks_cluster" "this" {
  for_each = var.ekscluster

  name                          = each.value.cluster_name
  role_arn                      = aws_iam_role.eks_cluster_role.arn #aws_iam_role.eks_cluster_role[each.key].arn #
  version                       = each.value.cluster_version
  enabled_cluster_log_types     = each.value.cluster_enabled_log_types
  bootstrap_self_managed_addons = each.value.bootstrap_self_managed_addons

  access_config {
    authentication_mode                         = each.value.authentication_mode
    bootstrap_cluster_creator_admin_permissions = each.value.bootstrap_cluster_creator_admin_permissions
  }

  vpc_config {
    #vpc_id                  = each.value.vpc_id
    security_group_ids      = [aws_security_group.eks_sg.id]
    subnet_ids              = each.value.subnet_ids
    endpoint_private_access = try(each.value.cluster_endpoint_private_access, true)
    endpoint_public_access  = try(each.value.cluster_endpoint_public_access, false)
    public_access_cidrs     = each.value.cluster_endpoint_public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    for_each = each.value.enable_kubernetes_network_config ? [1] : []

    content {
      ip_family         = each.value.cluster_ip_family
      service_ipv4_cidr = each.value.cluster_service_ipv4_cidr
      #service_ipv6_cidr = each.value.cluster_service_ipv6_cidr
    }
  }

  #   dynamic "encryption_config" {
  #     for_each = each.value.enable_cluster_encryption_config ? [1] : []

  #     content {
  #       provider {
  #         key_arn = each.value.create_kms_key ? module.kms.key_arn : each.value.cluster_encryption_config.provider_key_arn
  #       }
  #       resources = each.value.cluster_encryption_config.resources
  #     }
  #   }

  # dynamic "encryption_config" {
  #   for_each = each.value.enable_cluster_encryption_config ? [1] : []

  #   content {
  #     provider {
  #       key_arn = try(each.value.create_kms_key, false) ? module.kms.key_arn : lookup(each.value, "cluster_encryption_config.provider_key_arn", null)
  #     }
  #     resources = each.value.cluster_encryption_config.resources
  #   }
  # }

  dynamic "upgrade_policy" {
    for_each = each.value.enable_upgrade_policy #? [1] : []

    content {
      support_type = each.value.enable_upgrade_policy
    }
  }


  # dynamic "zonal_shift_config" {
  #   for_each = each.value.enable_zonal_shift ? [1] : []

  #   content {
  #     enabled = each.value.zonal_shift_enabled

  #   }
  # }

  tags = merge(
    { terraform-aws-modules = "eks" },
    each.value.tags,
    var.cluster_tags,
  )

  timeouts {
    create = try(each.value.cluster_timeouts.create, "30m") # Default timeout
    update = try(each.value.cluster_timeouts.update, "30")  # Default timeout
    delete = try(each.value.cluster_timeouts.delete, "30m") # Default timeout
  }

  depends_on = [
    # aws_iam_role_policy_attachment.this,
    # aws_security_group_rule.cluster,
    aws_security_group.eks_sg,
    aws_iam_role.eks_cluster_role
  ]

  lifecycle {
    ignore_changes = [
      access_config[0].bootstrap_cluster_creator_admin_permissions
    ]
  }
}
