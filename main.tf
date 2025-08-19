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
  db_host       = module.db.db_host
  db_secret_arn = module.db.db_secret_arn
  db_name       = var.db_name
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

###############################################
#resource "aws_iam_role" "debug_task_role" {
#  name = "mariam-debug-task-role-3ekNDw"
#
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [{
#      Effect = "Allow"
#      Principal = {
#        Service = "ecs-tasks.amazonaws.com"
#      }
#      Action = "sts:AssumeRole"
#    }]
#  })
#}
#
#resource "random_id" "suffix" {
#  byte_length = 4
#}
#
#resource "aws_iam_role_policy_attachment" "debug_task_execution" {
#  role       = aws_iam_role.debug_task_role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
#}
#
#resource "aws_iam_role_policy_attachment" "debug_ssm" {
#  role       = aws_iam_role.debug_task_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
#}
#
#output "suffix" {
#  value = random_id.suffix
#}