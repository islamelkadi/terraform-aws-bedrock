# Basic Code Interpreter Example

module "code_interpreter" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description        = var.description
  network_mode       = var.network_mode
  execution_role_arn = var.execution_role_arn

  tags = var.tags
}
