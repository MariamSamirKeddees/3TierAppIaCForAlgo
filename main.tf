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

module "nat" {
  source            = "./modules/nat"
  azs               = var.azs
  public_subnet_ids = module.subnets.public_subnet_ids
}

module "alb" {
  source             = "./modules/alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  security_group_ids = [module.sg.security_group_ids["mariam-alb_sg-IaC"]]
}

module "sg" {
  source          = "./modules/security_groups"
  vpc_id          = module.vpc.vpc_id
  security_groups = var.security_groups
}
