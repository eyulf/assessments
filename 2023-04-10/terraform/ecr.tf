### Registry

resource "aws_ecr_registry_scanning_configuration" "ecs_repos" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

### Repository

resource "aws_ecr_repository" "app_2048" {
  name                 = "${local.environment}-2048"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_alias.cicd.target_key_arn
  }
}

resource "aws_ecr_lifecycle_policy" "app_2048" {
  repository = aws_ecr_repository.app_2048.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 5 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
