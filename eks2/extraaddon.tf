add more add-ons, simply expand the addons map in the root module:


addons = {
  "vpc-cni" = { ... },
  "core-dns" = { ... },
  "kube-proxy" = { ... },
  "cloudwatch" = { ... },
  "my-custom-addon" = {
    version                  = "v1.0.0"
    service_account_role_arn = "arn:aws:iam::123456789012:role/my-addon-role"
    config                   = { "key" = "value" }
  }
}


