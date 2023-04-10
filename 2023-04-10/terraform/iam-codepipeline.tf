### IAM Role

resource "aws_iam_role" "codepipeline" {
  name_prefix = "codepipeline-${local.environment}-"

  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    sid     = "AllowRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

### IAM Policy

resource "aws_iam_role_policy" "codepipeline" {
  name_prefix = "app_2048"
  role        = aws_iam_role.codepipeline.id
  policy      = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    sid    = "S3"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.codepipeline.arn,
      "${aws_s3_bucket.codepipeline.arn}/*"
    ]
  }

  statement {
    sid    = "CodeCommit"
    effect = "Allow"
    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMS"
    effect = "Allow"
    actions = ["kms:*"]
    resources = [aws_kms_alias.cicd.target_key_arn]
  }

  #checkov:skip=CKV_AWS_109:Skipping Constraints for now
  #checkov:skip=CKV_AWS_111:Skipping Constraints for now
}
