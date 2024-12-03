# # Scaling policies for clusters
# scaling_policies = {
#   prod_cluster = {
#     scale_out_min       = 3
#     scale_out_max       = 8
#     scale_out_desired   = 5
#     scale_in_min        = 2
#     scale_in_max        = 4
#     scale_in_desired    = 3
#   }
#   dev_cluster = {
#     scale_out_min       = 2
#     scale_out_max       = 6
#     scale_out_desired   = 4
#     scale_in_min        = 1
#     scale_in_max        = 3
#     scale_in_desired    = 2
#   }
# }

# # Define clusters to create
# clusters = {
#   prod_cluster = { cluster_name = "prod-cluster" }
#   dev_cluster  = { cluster_name = "dev-cluster" }
# }

# # Override configurations for specific clusters
# custom_overrides = {
#   prod_cluster = {
#     node_ami_id           = "ami-prod123"
#     node_instance_type    = "t3.large"
#     node_desired_capacity = 4
#     node_max_size         = 10
#     node_min_size         = 2
#     subnet_ids            = ["subnet-abc123"]
#   }
#   dev_cluster = {
#     node_ami_id           = "ami-dev123"
#     node_instance_type    = "t3.medium"
#     node_desired_capacity = 2
#     node_max_size         = 6
#     node_min_size         = 1
#     subnet_ids            = ["subnet-def456"]
#   }
# }
