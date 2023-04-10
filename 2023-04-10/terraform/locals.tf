locals {
  account_id  = "123456789123"
  region      = "ap-southeast-2"
  environment = "assessment"
  zone        = "alexgardner.id.au"

  vpc_cidr = "10.10.0.0/18"
  vpc_availability_zones = [
    "ap-southeast-2a",
    "ap-southeast-2b",
  ]
  vpc_public_subnets = [
    "10.10.0.0/24",
    "10.10.1.0/24",
  ]
  vpc_private_subnets = [
    "10.10.10.0/24",
    "10.10.11.0/24",
  ]
}
