module "networking_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "4.0.1"

  vpc_id = module.networking.vpc_id

  endpoints = {
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.networking.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.networking.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    }
  }
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    sid       = "DenyRequestsFromOutsideVPC"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"
      values   = [module.networking.vpc_id]
    }
  }
}
