module "vpc" {
  source = "git::https://github.com/prabalark/tf-module-vpc.git"

  for_each = var.vpc
  cidr_block = each.value["cidr_block"]
  subnets = each.value["subnets"]
  tags = local.tags
  env = var.env
  default_vpc_id = var.default_vpc_id
  default_vpc_cidr = var.default_vpc_cidr
  default_vpc_rtid = var.default_vpc_rtid
}

module "web" {
  source = "git::https://github.com/prabalark/tf-module-app.git"

  for_each      = var.app
  instance_type = each.value["instance_type"]
  name          = each.value["name"]
  desired_capacity = each.value["desired_capacity"]
  max_size         = each.value["max_size"]
  min_size         = each.value["min_size"]
  tags         = merge(local.tags, { Monitor = "true" })
  env= var.env
  bastion_cidr=var.bastion_cidr

  subnet_id = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["subnet_name"],null),"subnet_ids",null )
  vpc_id = lookup(lookup(module.vpc,"main",null),"vpc_id",null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["allow_app_cidr"],null),"subnet_cidrs",null )
}

