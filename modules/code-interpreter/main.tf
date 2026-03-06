# Bedrock AgentCore Code Interpreter Module
# Secure Python code execution environment for AI agents

# Local variables
locals {
  # Sanitize name for AWS Bedrock requirements: max 48 chars, alphanumeric + underscore only
  code_interpreter_name = replace(
    substr(
      "${var.namespace}_${var.environment}_${var.name}",
      0,
      48
    ),
    "-",
    "_"
  )

  # Tags
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Module      = "terraform-aws-bedrock/code-interpreter"
      Description = "Code Interpreter for dynamic calculations"
    }
  )
}

# Code Interpreter Resource
resource "aws_bedrockagentcore_code_interpreter" "this" {
  name               = local.code_interpreter_name
  description        = var.description != "" ? var.description : "Code Interpreter ${local.code_interpreter_name}"
  execution_role_arn = var.execution_role_arn

  # Network configuration (required)
  network_configuration {
    network_mode = var.network_mode

    # VPC configuration (only for VPC mode)
    dynamic "vpc_config" {
      for_each = var.network_mode == "VPC" && var.vpc_config != null ? [var.vpc_config] : []
      content {
        security_groups = vpc_config.value.security_group_ids
        subnets         = vpc_config.value.subnet_ids
      }
    }
  }

  tags = local.tags
}
