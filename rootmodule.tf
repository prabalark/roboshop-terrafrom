module "vpc" {
  source = "git::https://github.com/prabalark/tf-module-vpc.git"

  for_each = var.vpc
  cidr_block = each.value["cidr_block"]
  subnets = each.value["subnets"]
  tags = local.tags
  env = var.env

}

module "web" {
  source = "git::https://github.com/prabalark/tf-module-app.git"

  for_each      = var.app
  instance_type = each.value["instance_type"]
  name =each.value["name"]


  env= var.env
  bastion_cidr=var.bastion_cidr

  subnet_id = element(lookup(lookup(lookup(lookup(module.vpc,"main",null),"subnets",null),each.value["subnet_name"],null),"subnet_ids",null ),0)
}


variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}

variable "vpc_id" {}
variable "allow_app_cidr" {}
