### IAM Role

resource "aws_iam_role" "codedeploy" {
  name_prefix = "codedeploy-${local.environment}-"

  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json
}

data "aws_iam_policy_document" "codedeploy_assume_role" {
  statement {
    sid     = "AllowRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

### IAM Policy

resource "aws_iam_role_policy" "codedeploy" {
  name_prefix = "app_2048"
  role        = aws_iam_role.codedeploy.id
  policy      = data.aws_iam_policy_document.codedeploy.json
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    sid    = "AllowECS"
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:DeleteTaskSet",
      "ecs:UpdateServicePrimaryTaskSet"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowECSTask"
    effect    = "Allow"
    actions   = ["ecs:CreateTaskSet"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowALB"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowPassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }

  #checkov:skip=CKV_AWS_109:Skipping Constraints for now
  #checkov:skip=CKV_AWS_111:Skipping Constraints for now
}
