# Basic AgentCore Runtime Example

module "agentcore_runtime" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description
  role_arn    = var.role_arn

  code_configuration = {
    entry_point = ["app.py", "handler"]
    runtime     = "PYTHON_3_13"
    s3_bucket   = var.s3_bucket
    s3_key      = var.s3_key
  }

  vpc_config = {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment_variables = {
    LOG_LEVEL           = "INFO"
    DYNAMODB_TABLE_NAME = "corporate-actions"
  }

  tags = var.tags
}
