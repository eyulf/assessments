resource "aws_codepipeline" "app_2048" {
  name     = "${local.environment}-2048"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_alias.cicd.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.app_2048.repository_name
        BranchName     = "nginx_ecs_public"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"
      region   = local.region

      input_artifacts  = ["source_output"]
      output_artifacts = ["task"]

      configuration = {
        ProjectName = aws_codebuild_project.app_2048.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["task"]
      version         = "1"

      configuration = {
        ApplicationName                = "${local.environment}-2048"
        DeploymentGroupName            = "${local.environment}-2048"
        TaskDefinitionTemplateArtifact = "task"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "task"
        AppSpecTemplatePath            = "appspec.yaml"
      }
    }
  }
}
