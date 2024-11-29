# modules/eks/main.tf
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Any other EKS configuration you need
}

# Define EKS add-ons
resource "aws_eks_addon" "addon" {
  for_each = var.addons

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.key
  addon_version = each.value.version
  service_account_role_arn = each.value.service_account_role_arn

  # Optional: Define configuration for specific add-ons
  config {
    key = each.value.config.key
    value = each.value.config.value
  }
}
