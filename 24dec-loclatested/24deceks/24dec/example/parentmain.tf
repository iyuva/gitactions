module "eks" {
  source = "C:/Users/venkat/Desktop/New folder (2)/24dec/24dec/module" # Path to the EKS module

  ekscluster   = var.ekscluster   # Pass the ekscluster variable
  cluster_tags = var.cluster_tags # Pass the cluster_tags variable (if necessary)
  vpc_id       = var.vpc_id

}
