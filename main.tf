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
  source              = "./modules/route_tables"
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.igw.igw_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
  be_subnet_ids       = var.be_subnet_ids
  azs                 = var.azs
  az_to_public_subnet = module.nat.az_to_public_subnet
  nat_gateway_ids     = module.nat.nat_gateway_ids
  fe_subnet_ids       = var.fe_subnet_ids 
  
}

module "nat" {
  source            = "./modules/nat"
  azs               = var.azs
  public_subnet_ids = module.subnets.public_subnet_ids
  be_subnet_ids  = var.be_subnet_ids  
  private_rt_nat_ids = module.route_tables.private_rt_nat_ids
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

module "asg" {
  source = "./modules/asg"
  name                = "mariam-fe-asg"
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  key_name            = var.key_name
  target_group_arns   = [module.alb.fe_tg_arn]
  fe_subnet_ids       = var.fe_subnet_ids
  fe_sg_id            = module.sg.security_group_ids["mariam-fe_sg-IaC"]

}
module "ecs_backend" {
  source = "./modules/ecs"

  name               = "mariam-be-ecs"
  container_image    = "tiangolo/uwsgi-nginx-flask:python3.8"
  be_subnet_ids = ["subnet-082ca8d172401961a", "subnet-0b3b99ae42959fd86"]
  be_sg_id      = module.sg.be_sg_id
  be_tg_arn     = module.alb.be_tg_arn
}

module "db" {
  source            = "./modules/db"
  db_prefix_name    = var.db_prefix_name
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  multi_az          = var.multi_az
  db_name           = var.db_name
  db_subnet_ids     = var.db_subnet_ids
  db_sg_id          = var.db_sg_id
  #db_host          = aws_db_instance.this.address  
  db_username       = var.db_username
}
