# Primary Module Example - This demonstrates the terraform-aws-bedrock agentcore-runtime module
# Supporting infrastructure (VPC) is defined in separate files
# to keep this example focused on the module's core functionality.
#
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

  # Direct reference to vpc.tf module outputs
  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.security_group.security_group_id]
  }

  environment_variables = {
    LOG_LEVEL           = "INFO"
    DYNAMODB_TABLE_NAME = "corporate-actions"
  }

  tags = var.tags
}
