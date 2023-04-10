### IAM Role

resource "aws_iam_role" "codebuild" {
  name_prefix = "codebuild-${local.environment}-"

  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    sid     = "AllowRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

### IAM Policy

resource "aws_iam_role_policy" "codebuild" {
  name_prefix = "app_2048"
  role        = aws_iam_role.codebuild.id
  policy      = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid    = "AllowS3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.codepipeline.arn,
      "${aws_s3_bucket.codepipeline.arn}/*",
    ]
  }

  statement {
    sid    = "AllowKMSAccess"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = [aws_kms_alias.cicd.target_key_arn]
  }

  statement {
    sid    = "AllowECRAuthAccess"
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowECRAccess"
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [aws_ecr_repository.app_2048.arn]
  }

  statement {
    sid    = "AllowLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.app_2048_codebuild.arn,
      "${aws_cloudwatch_log_group.app_2048_codebuild.arn}:*"
    ]
  }

  #checkov:skip=CKV_AWS_109:TODO Fine tune Least-Privilege access
  #checkov:skip=CKV_AWS_111:TODO Fine tune Least-Privilege access
}
