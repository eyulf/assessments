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

provider "aws" {
  alias  = "global"

  region              = "us-east-1"
  allowed_account_ids = [local.account_id]

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = local.environment
    }
  }
}
