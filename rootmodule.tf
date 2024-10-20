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

module "web" { # app
  depends_on = [module.vpc, module.docdb, module.rds, module.elasticache, module.rabbitmq, module.alb]
  source = "git::https://github.com/prabalark/tf-module-app.git"

  for_each      = var.app
  instance_type = each.value["instance_type"]
  name          = each.value["name"]
  desired_capacity = each.value["desired_capacity"]
  max_size         = each.value["max_size"]
  min_size         = each.value["min_size"]
  app_port         = each.value["app_port"]

  listener_priority =each.value["listener_priority"]
  listener_arn  = lookup(lookup(module.alb, each.value["lb_type"], null), "listener_arn", null)
     # check lb_type : public & private | listener_arn in tf-loadbal in outputs.tf
  domain_name = var.domain_name

  domain_id   = var.domain_id

  dns_name    = each.value["name"] == "frontend" ? each.value["dns_name"] : "${each.value["name"]}-${var.env}"
     # cond-1 in router53 : only for frontend we require starting like -> dev.de72..
       # remaining cata.dev.de72 etc for this in rootmodule kept condition
     # cond-2 : otherwise give variable in main.tfvars give names in each web/app server

  lb_dns_name = lookup(lookup(module.alb, each.value["lb_type"], null), "dns_name1", null) #tf-laodbal-output.tf

  tags             = merge(local.tags, { Monitor = "true" })
  env              = var.env
  bastion_cidr     = var.bastion_cidr

  subnets = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["subnet_name"],null),"subnet_ids",null )
  vpc_id = lookup(lookup(module.vpc,"main",null),"vpc_id",null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["allow_app_cidr"],null),"subnet_cidrs",null )

}

module "docdb" {
  source = "git::https://github.com/prabalark/tf-module-docdb.git"

  for_each       = var.docdb
  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]
  env            = var.env
  kms_arn        = var.kms_arn
  vpc_id         = local.vpc_id
  tags           = local.tags
  subnets = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["subnet_name"],null),"subnet_ids",null )
  # keeping in local.tf : vpc_id = lookup(lookup(module.vpc,"main",null),"vpc_id",null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["allow_db_cidr"],null),"subnet_cidrs",null )
}

module "rds" {
  source = "git::https://github.com/prabalark/tf-module-rds.git"

  for_each       = var.rds
  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]

  env     = var.env
  kms_arn = var.kms_arn
  vpc_id  = local.vpc_id
  tags    = local.tags

  subnets        = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_db_cidr  = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
}

module "elasticache" {
  source = "git::https://github.com/prabalark/tf-module-elasticache.git"

  for_each                = var.elasticache
  engine_version          = each.value["engine_version"]
  replicas_per_node_group = each.value["replicas_per_node_group"]
  num_node_groups         = each.value["num_node_groups"]
  node_type               = each.value["node_type"]

  env     = var.env
  kms_arn = var.kms_arn
  vpc_id  = local.vpc_id
  tags    = local.tags

  subnets                 = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_db_cidr           = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)

}

module "rabbitmq" {
  source = "git::https://github.com/prabalark/tf-module-amazon-mq.git"

  for_each      = var.rabbitmq
  instance_type = each.value["instance_type"]

  env          = var.env
  kms_arn      = var.kms_arn
  bastion_cidr = var.bastion_cidr
  #domain_id    = var.domain_id

  vpc_id       = local.vpc_id
  tags         = local.tags

  subnets       = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)

}


module "alb" {
  source = "git::https://github.com/prabalark/tf-module-loadbal.git"

  for_each       = var.alb
  name           = each.value["name"]
  internal       = each.value["internal"]

  tags   = local.tags
  env    = var.env

  vpc_id = local.vpc_id
  subnets        = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  allow_alb_cidr = each.value["name"] == "public" ? ["0.0.0.0/0"] : concat(lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_alb_cidr"], null), "subnet_cidrs", null), lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), "app", null), "subnet_cidrs", null))

}







