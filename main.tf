module "vpc" {
  source = "./Modules/vpc"
}

module "ec2" {
  source                = "./Modules/ec2"
  public_subnet_id_var  = module.vpc.public_subnet_id[*]
  private_subnet_id_var = module.vpc.private_subnet_id[*]
}