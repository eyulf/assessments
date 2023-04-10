### OpenID

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  thumbprint_list = ["f879abce0008e4eb126e0097e46620f5aaae26ad"] # token.actions.githubusercontent.com (10/04/2023)
}

### IAM Role

resource "aws_iam_role" "github" {
  name = "openid-github"

  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    sid     = "AllowRoleAssumptionWithWebIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = ["repo:eyulf/assessments:*"]
    }
  }
}

### IAM Policy

resource "aws_iam_role_policy" "openid_github" {
  name   = "OpenIdGithub"
  role   = aws_iam_role.github.id
  policy = data.aws_iam_policy_document.openid_github.json
}

data "aws_iam_policy_document" "openid_github" {
  statement {
    sid    = "CodeCommitAccess"
    effect = "Allow"
    actions = [
      "codecommit:GitPull",
      "codecommit:GitPush",
    ]
    resources = [aws_codecommit_repository.app_2048.arn]
  }
}
