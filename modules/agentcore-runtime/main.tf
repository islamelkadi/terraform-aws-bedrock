# Bedrock AgentCore Runtime Module
# Purpose-built serverless runtime for AI agents

# Local variables
locals {
  # Sanitize name to meet AWS requirements: ^[a-zA-Z][a-zA-Z0-9_]{0,47}$
  # Max 48 chars, alphanumeric + underscore only, must start with letter
  sanitized_name = replace(module.metadata.resource_prefix, "-", "_")
  runtime_name   = substr(local.sanitized_name, 0, min(48, length(local.sanitized_name)))

  # Merge security controls with overrides
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = true
      require_encryption_at_rest    = true
      require_encryption_in_transit = true
      enable_kms_key_rotation       = true
    }
    logging = {
      require_cloudwatch_logs = true
      min_log_retention_days  = 365
      require_access_logging  = false
      require_flow_logs       = false
    }
    monitoring = {
      enable_xray_tracing         = true
      enable_enhanced_monitoring  = false
      enable_performance_insights = false
      require_cloudtrail          = false
    }
    network = {
      require_private_subnets = true
      require_vpc_endpoints   = false
      block_public_ingress    = true
      require_imdsv2          = false
    }
    compliance = {
      enable_point_in_time_recovery = false
      require_reserved_concurrency  = false
      enable_deletion_protection    = false
    }
    data_protection = {
      require_versioning  = false
      require_mfa_delete  = false
      require_backup      = false
      require_lifecycle   = false
      block_public_access = true
      require_replication = false
    }
  }

  # Determine network mode based on VPC configuration
  network_mode = var.vpc_config != null ? "VPC" : "PUBLIC"

  # Tags
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Module      = "terraform-aws-bedrock/agentcore-runtime"
      Description = "AgentCore Runtime for AI agent execution"
    }
  )
}

# AgentCore Runtime Resource
resource "aws_bedrockagentcore_agent_runtime" "this" {
  agent_runtime_name = local.runtime_name
  description        = var.description != "" ? var.description : "AgentCore Runtime ${local.runtime_name}"
  role_arn           = var.role_arn

  # Agent runtime artifact configuration
  agent_runtime_artifact {
    # Code configuration (S3-based deployment)
    dynamic "code_configuration" {
      for_each = var.code_configuration != null ? [var.code_configuration] : []
      content {
        entry_point = code_configuration.value.entry_point
        runtime     = code_configuration.value.runtime

        code {
          s3 {
            bucket     = code_configuration.value.s3_bucket
            prefix     = code_configuration.value.s3_key
            version_id = code_configuration.value.s3_version_id
          }
        }
      }
    }

    # Container configuration (ECR-based deployment)
    dynamic "container_configuration" {
      for_each = var.container_configuration != null ? [var.container_configuration] : []
      content {
        container_uri = container_configuration.value.container_uri
      }
    }
  }

  # Network configuration
  network_configuration {
    network_mode = local.network_mode

    # VPC configuration (only when network_mode is VPC)
    dynamic "network_mode_config" {
      for_each = var.vpc_config != null ? [var.vpc_config] : []
      content {
        security_groups = network_mode_config.value.security_group_ids
        subnets         = network_mode_config.value.subnet_ids
      }
    }
  }

  # Environment variables
  environment_variables = var.environment_variables

  # Authorization configuration
  dynamic "authorizer_configuration" {
    for_each = var.authorizer_configuration != null ? [var.authorizer_configuration] : []
    content {
      dynamic "custom_jwt_authorizer" {
        for_each = authorizer_configuration.value.custom_jwt_authorizer != null ? [authorizer_configuration.value.custom_jwt_authorizer] : []
        content {
          discovery_url    = custom_jwt_authorizer.value.discovery_url
          allowed_audience = custom_jwt_authorizer.value.allowed_audiences
          allowed_clients  = custom_jwt_authorizer.value.allowed_clients
        }
      }
    }
  }

  # Lifecycle configuration
  dynamic "lifecycle_configuration" {
    for_each = var.lifecycle_configuration != null ? [var.lifecycle_configuration] : []
    content {
      idle_runtime_session_timeout = lifecycle_configuration.value.idle_runtime_session_timeout
      max_lifetime                 = lifecycle_configuration.value.max_lifetime
    }
  }

  # Protocol configuration
  dynamic "protocol_configuration" {
    for_each = var.protocol_configuration != null ? [var.protocol_configuration] : []
    content {
      server_protocol = protocol_configuration.value.server_protocol
    }
  }

  # Request header configuration
  dynamic "request_header_configuration" {
    for_each = var.request_header_configuration != null ? [var.request_header_configuration] : []
    content {
      request_header_allowlist = request_header_configuration.value.request_header_allowlist
    }
  }

  tags = local.tags
}

# Security validations
check "security_controls_compliance" {
  assert {
    condition     = !local.security_controls.network.require_private_subnets || var.vpc_config != null || var.security_control_overrides.disable_vpc_requirement
    error_message = "Security control violation: VPC configuration is required for private subnet deployment. Set security_control_overrides.disable_vpc_requirement=true with justification if this is intentional."
  }

  assert {
    condition     = !local.security_controls.network.require_private_subnets || var.vpc_config == null || var.security_control_overrides.disable_vpc_requirement || local.network_mode == "VPC"
    error_message = "Security control violation: Network mode must be VPC when VPC configuration is provided."
  }

  assert {
    condition     = var.security_control_overrides.disable_vpc_requirement == false || var.security_control_overrides.justification != ""
    error_message = "Security control overrides detected but no justification provided. Please provide justification for disabling VPC requirement."
  }
}
