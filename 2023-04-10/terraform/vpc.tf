module "networking" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"

  name = local.environment
  cidr = local.vpc_cidr

  azs             = local.vpc_availability_zones
  public_subnets  = local.vpc_public_subnets
  private_subnets = local.vpc_private_subnets

  create_database_subnet_route_table = true
  enable_dns_hostnames               = true
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  one_nat_gateway_per_az             = false
}
