# main.tf

module "eks" {
  source = "./modules/eks"

  cluster_name        = "my-eks-cluster"
  cluster_role_arn    = "arn:aws:iam::123456789012:role/eks-cluster-role"
  subnet_ids          = ["subnet-12345", "subnet-67890"]
  addons = {
    "vpc-cni" = {
      version                  = "v1.10.0-eksbuild.1"
      service_account_role_arn = "arn:aws:iam::123456789012:role/vpc-cni-role"
      config                   = {}
    },
    "core-dns" = {
      version                  = "v1.8.0-eksbuild.1"
      service_account_role_arn = "arn:aws:iam::123456789012:role/coredns-role"
      config                   = {}
    },
    "kube-proxy" = {
      version                  = "v1.23.7-eksbuild.1"
      service_account_role_arn = "arn:aws:iam::123456789012:role/kube-proxy-role"
      config                   = {}
    },
    "cloudwatch" = {
      version                  = "v1.0.2"
      service_account_role_arn = "arn:aws:iam::123456789012:role/cloudwatch-role"
      config                   = {}
    }
  }
}
