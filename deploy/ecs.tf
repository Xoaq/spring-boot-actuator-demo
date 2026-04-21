# --- AWS ECS Cluster ---
resource "aws_ecs_cluster" "main" {
  name = "lp-pedidos-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled" # Habilitado para mejor visibilidad en CloudWatch
  }
}

# --- ECS Service con Fargate ---
resource "aws_ecs_service" "app" {
  name            = "lp-pedidos-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2 # Iniciamos con 2 tareas para Alta Disponibilidad (High Availability)
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app-pedidos"
    container_port   = 8080
  }
}

# --- ESTRATEGIA DE ESCALAMIENTO (Resiliencia) ---

# 1. Definir el objetivo de escalado
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# 2. Política de escalamiento basada en CPU
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "lp-pedidos-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    # Se elige 70% como umbral para permitir un margen de maniobra 
    # mientras se levantan nuevas instancias sin degradar la experiencia del usuario
    target_value = 70.0 
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}