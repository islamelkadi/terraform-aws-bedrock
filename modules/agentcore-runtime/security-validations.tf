# Security validations for AgentCore Runtime

# Additional security checks are defined in main.tf using check blocks
# This file can be extended with additional security validations as needed

# Validation: Ensure either code_configuration or container_configuration is provided
locals {
  has_code_config      = var.code_configuration != null
  has_container_config = var.container_configuration != null
  has_exactly_one      = (local.has_code_config && !local.has_container_config) || (!local.has_code_config && local.has_container_config)
}

check "artifact_configuration" {
  assert {
    condition     = local.has_exactly_one
    error_message = "Exactly one of code_configuration or container_configuration must be specified."
  }
}

# Validation: VPC configuration must include both subnets and security groups
check "vpc_configuration" {
  assert {
    condition     = var.vpc_config == null || (length(var.vpc_config.subnet_ids) > 0 && length(var.vpc_config.security_group_ids) > 0)
    error_message = "VPC configuration must include at least one subnet and one security group."
  }
}

# Validation: Environment variables should not contain sensitive data in plain text
check "environment_variables_security" {
  assert {
    condition = alltrue([
      for key, value in var.environment_variables :
      !can(regex("(?i)(password|secret|key|token|credential)", key))
    ])
    error_message = "Environment variable names suggest sensitive data. Use AWS Secrets Manager or Parameter Store for sensitive values and reference them in your code."
  }
}
