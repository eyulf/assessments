resource "aws_codebuild_project" "app_2048" {
  name         = "${local.environment}-2048"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = local.codebuild_environment_variables

      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = lookup(environment_variable.value, "type", "PLAINTEXT")
      }
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/templates/buildspec-app-2048.yaml")
  }
}

resource "aws_cloudwatch_log_group" "app_2048_codebuild" {
  name              = "/aws/codebuild/${local.environment}-2048"
  retention_in_days = 3

  #checkov:skip=CKV_AWS_158:Choosing not to encrypt logs for now
}

locals {
  codebuild_environment_variables = [
    {
      "name"  = "AWS_DEFAULT_REGION",
      "value" = local.region,
    },
    {
      "name"  = "AWS_ACCOUNT_ID",
      "value" = local.account_id,
    },
    {
      "name"  = "REPOSITORY_URI",
      "value" = aws_ecr_repository.app_2048.repository_url
    },
    {
      "name"  = "IMAGE_TAG",
      "value" = "app-2048",
    },
    {
      "name"  = "APP_NAME",
      "value" = "${local.environment}-2048",
    },
    {
      "name"  = "SERVICE_PORT",
      "value" = "80",
    },
    {
      "name"  = "IAM_EXEC_ROLE",
      "value" = aws_iam_role.ecs_task_exec.arn,
    },
    {
      "name"  = "CPU",
      "value" = "256",
    },
    {
      "name"  = "MEMORY",
      "value" = "512",
    }
  ]
}
