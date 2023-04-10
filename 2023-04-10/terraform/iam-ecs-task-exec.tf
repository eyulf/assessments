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

