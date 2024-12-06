# terraform.tfvars (Parent Module)

node_group_name            = "my-node-group"
cluster_name               = "my-cluster"
subnet_ids                 = ["subnet-xxxxxx", "subnet-yyyyyy"]
min_size                   = 2
max_size                   = 5
desired_size               = 3
ami_type                   = "AL2"
release_version            = "1.21"
eks_version                = "1.21"
capacity_type              = "ON_DEMAND"
disk_size                  = 20
launch_template            = false
launch_template_id         = ""
launch_template_version    = ""
remote_access_enabled      = false
ssh_key_name               = "my-ssh-key"
ssh_security_group_ids     = []
taints                     = []
update_config_enabled      = false
max_unavailable_percentage = 50
max_unavailable            = 1
timeouts                   = { create = "30m", update = "30m", delete = "30m" }
tags                       = { "Environment" = "production", "Owner" = "team-x" }
schedules                  = {}
create_schedule            = false
