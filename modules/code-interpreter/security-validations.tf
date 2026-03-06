# Security Validations
# Terraform check blocks for security control compliance

# Validation: Network mode requirements
check "network_mode_validation" {
  assert {
    condition     = var.network_mode == "SANDBOX" || var.network_mode == "VPC" || var.security_control_overrides.disable_sandbox_requirement
    error_message = "Security control violation: Code Interpreter should use SANDBOX or VPC network mode for isolation. Set security_control_overrides.disable_sandbox_requirement=true with justification if PUBLIC mode is required."
  }

  assert {
    condition     = var.network_mode != "VPC" || var.vpc_config != null
    error_message = "VPC configuration is required when network_mode is VPC."
  }

  assert {
    condition     = var.network_mode != "SANDBOX" || var.execution_role_arn != null
    error_message = "Execution role ARN is required when network_mode is SANDBOX."
  }
}

# Validation: Security control overrides audit trail
check "override_justification" {
  assert {
    condition     = !var.security_control_overrides.disable_sandbox_requirement || var.security_control_overrides.justification != ""
    error_message = "Security control overrides detected but no justification provided. Please provide justification for disabling SANDBOX requirement."
  }
}
