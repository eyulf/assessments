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

  #checkov:skip=CKV2_AWS_1:False positive, module does add all NACLs to subnets
  #checkov:skip=CKV2_AWS_11:Flow Logging not required due to cost
  #checkov:skip=CKV2_AWS_12:Default VPC not used
  #checkov:skip=CKV2_AWS_19:EIPs are used in NAT GW
  #checkov:skip=CKV_AWS_130:Default VPC not used
}
