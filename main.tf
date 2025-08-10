module "vpc" {
  source    = "./modules/vpc"
  vpc_cidr  = var.vpc_cidr
}

module "subnets" {
  source          = "./modules/subnets"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "igw" {
  source    = "./modules/igw"
  vpc_id    = module.vpc.vpc_id 
}

module "route_tables" {
  source    = "./modules/route_tables"
  vpc_id    = module.vpc.vpc_id
  igw_id    = module.igw.igw_id
  public_subnet_ids = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
}

#module "public_rt_assoc"{
#  source = "./modules/route_tables"
#
#}