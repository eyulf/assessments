provider "aws" {
  region              = local.region
  allowed_account_ids = [local.account_id]

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = local.environment
    }
  }
}
