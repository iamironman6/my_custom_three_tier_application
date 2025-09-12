provider "aws" {
  region = "us-east-1"
}

module "my_custom_vpc" {
  source                   = "./modules/vpc_module"
  vpc_cidr_block_value     = var.vpc_cidr_block_value
  pubsub1_cidr_block_value = var.pubsub1_cidr_block_value
  pubsub2_cidr_block_value = var.pubsub2_cidr_block_value
  pvtsub1_cidr_block_value = var.pvtsub1_cidr_block_value
  pvtsub2_cidr_block_value = var.pvtsub2_cidr_block_value
}

module "my_custom_sg_module" {
  source          = "./modules/sg_module"
  vpc_id          = module.my_custom_vpc.myvpc_id
  web_tier_subnet = var.web_tier_subnet
  app_tier_subnet = var.app_tier_subnet
  db_tier_subnet  = var.db_tier_subnet
}

module "my_custom_web_tier_module" {
  source         = "./modules/web_tier_module"
  vpc_id         = module.my_custom_vpc.myvpc_id
  web_tier_sg_id = module.my_custom_sg_module.web_tier_sg_id
  pub_sub1_id    = module.my_custom_vpc.pub_sub1_id
  pub_sub2_id    = module.my_custom_vpc.pub_sub2_id
  ami            = var.web_tier_ami
  instance_type  = var.web_tier_instance_type
  key_name       = var.key_name
  min_size       = var.web_tier_instance_min_size
  max_size       = var.web_tier_instance_max_size
  desired_size   = var.web_tier_instance_desired_size
}

module "my_custom_app_tier_module" {
  source         = "./modules/app_tier_module"
  vpc_id         = module.my_custom_vpc.myvpc_id
  ami_id         = var.app_tier_instance_ami_id
  instance_type  = var.app_tier_instance_type
  app_tier_sg_id = module.my_custom_sg_module.app_tier_sg_id
  pvt_sub1_id    = module.my_custom_vpc.pvt_sub1_id
  pvt_sub2_id    = module.my_custom_vpc.pvt_sub2_id
  key_name       = var.key_name
  min_size       = var.app_tier_instance_min_size
  max_size       = var.app_tier_instance_max_size
  desired_size   = var.app_tier_instance_desired_size
}

module "my_custome_db_tier_module" {
  source        = "./modules/db_tier_module"
  ami_id        = var.db_tier_instance_ami_id
  instance_type = var.db_tier_instance_type
  db_tier_sg_id = module.my_custom_sg_module.db_tier_sg_id
  pvt_sub1_id   = module.my_custom_vpc.pvt_sub1_id
  pvt_sub2_id   = module.my_custom_vpc.pvt_sub2_id
  key_name      = var.key_name
}

module "my_custom_bastion_module" {
  source             = "./modules/bastion_module"
  ami_id             = var.bastion_module_ami_id
  instance_type      = var.bastion_module_instance_type
  bastion_host_sg_id = module.my_custom_sg_module.bastion_sg_id
  pub_sub1_id        = module.my_custom_vpc.pub_sub1_id
  pub_sub2_id        = module.my_custom_vpc.pub_sub2_id
  key_name           = var.key_name
}

