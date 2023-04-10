### ECS Service

resource "aws_ecs_service" "main" {
  name    = "${local.environment}-2048"
  cluster = module.ecs.cluster_id

  task_definition = aws_ecs_task_definition.app_2048.arn
  desired_count   = 1

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 1
  }

  network_configuration {
    subnets         = module.networking.private_subnets
    security_groups = [aws_security_group.app_2048.id]
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

### ECS Task

resource "aws_ecs_task_definition" "app_2048" {
  family = "${local.environment}-2048"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn

  container_definitions = jsonencode([
    {
      name      = "APPNAME",
      image     = "IMAGE",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ],
      environment = [
        {
          name  = "PORT",
          value = "80"
        },
        {
          name  = "APP_NAME",
          value = "APPNAME"
        }
      ]
    }
  ])
}

### Security Group

resource "aws_security_group" "app_2048" {
  name        = "${local.environment}-2048-ecs-fargate"
  description = "Security group for ECS ${local.environment}-2048 in Fargate"
  vpc_id      = module.networking.vpc_id

  tags = {
    "Name" = "${local.environment}-2048-ecs-fargate"
  }
}
