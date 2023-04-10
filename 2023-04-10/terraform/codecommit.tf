resource "aws_codecommit_repository" "app_2048" {
  repository_name = "${local.environment}-2048"
}
