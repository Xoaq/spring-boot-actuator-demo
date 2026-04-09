resource "aws_ecs_cluster" "main" {
  name = "lp-pedidos-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "lp-pedidos-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  
  # Fix: Se requerirá inyectar un rol IAM gestionado por el módulo de seguridad
  # execution_role_arn       = data.aws_iam_role.ecs_exec.arn

  container_definitions = jsonencode([
    {
      name      = "lp-pedidos-container-${var.environment}"
      image     = var.app_image
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      # TODO: Implementar rotación de secretos en AWS Secrets Manager para credenciales DB
      environment = [
        { name = "SPRING_PROFILES_ACTIVE", value = var.environment }
      ]
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "lp-pedidos-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.environment == "prod" ? 3 : 1
  launch_type     = "FARGATE"

  network_configuration {
    # Fix: Reemplazadas subnets hardcodeadas por los recursos de la VPC aprovisionada
    subnets          = aws_subnet.private[*].id
    # TODO: Reemplazar el SG hardcodeado por un recurso aws_security_group dinámico
    security_groups  = ["sg-zzzzzzzz"]
    assign_public_ip = false
  }
}
