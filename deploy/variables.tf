variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Entorno objetivo para modularización (ej. dev, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "Bloque CIDR para la VPC"
  default     = "10.0.0.0/16"
}

variable "ecs_task_cpu" {
  type    = number
  description = "Unidades de CPU para la tarea ECS Fargate (completamente parametrizable)"
  default = 1024
}

variable "ecs_task_memory" {
  type    = number
  description = "Memoria en MB para la tarea ECS Fargate (completamente parametrizable)"
  default = 2048
}

variable "app_image" {
  type        = string
  description = "URI de la imagen de JFrog Artifactory inyectada por el pipeline"
}