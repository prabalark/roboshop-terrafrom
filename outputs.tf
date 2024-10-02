output "subnet_ids" {
  value = "module.subnets"
}

output "vpc" {
  value = lookup(module.vpc ,"main" ,null)
}