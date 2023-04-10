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

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_2048_blue.arn
    container_name   = "APPNAME"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer
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

resource "aws_security_group_rule" "app_2048_all_http_out" {
  description       = "Allow all outbound"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_2048.id
}
