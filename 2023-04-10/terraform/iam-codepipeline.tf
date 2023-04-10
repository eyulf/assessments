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
    resources = [aws_codecommit_repository.app_2048.arn]
  }

  statement {
    sid    = "KMS"
    effect = "Allow"
    actions = ["kms:*"]
    resources = [aws_kms_alias.cicd.target_key_arn]
  }

  statement {
    sid    = "Codebuild"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [aws_codebuild_project.app_2048.arn]
  }

  statement {
    sid    = "ECSCodeDeploy"
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetDeploymentConfig",
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "PassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ecs_task_exec.arn]
  }

  #checkov:skip=CKV_AWS_109:TODO Fine tune Least-Privilege access
  #checkov:skip=CKV_AWS_111:TODO Fine tune Least-Privilege access
}
