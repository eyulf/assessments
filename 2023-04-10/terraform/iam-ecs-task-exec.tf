### IAM Role

resource "aws_iam_role" "ecs_task_exec" {
  name_prefix = "ecs-task-exec-${local.environment}-"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_ecs_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_exec_ecs_assume_role" {
  statement {
    sid     = "AllowRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

### IAM Policy

resource "aws_iam_role_policy" "ecs_task_exec" {
  name_prefix = "app_2048"
  role        = aws_iam_role.ecs_task_exec.id
  policy      = data.aws_iam_policy_document.ecs_task_exec.json
}

data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    sid       = "AllowECRAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowECR"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
    ]
    resources = [
      aws_ecr_repository.app_2048.arn,
      "${aws_ecr_repository.app_2048.arn}/*",
    ]
  }
}
