# Bedrock AgentCore Runtime Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the AgentCore Runtime"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# AgentCore Runtime configuration
variable "description" {
  description = "Description of the AgentCore Runtime"
  type        = string
  default     = ""
}

variable "role_arn" {
  description = "ARN of the IAM role that the AgentCore Runtime assumes to access AWS services"
  type        = string
}

# Code configuration (S3-based deployment)
variable "code_configuration" {
  description = "Code configuration for S3-based deployment. Exactly one of code_configuration or container_configuration must be specified"
  type = object({
    entry_point   = list(string)
    runtime       = string
    s3_bucket     = string
    s3_key        = string
    s3_version_id = optional(string)
  })
  default = null

  validation {
    condition = var.code_configuration == null || (
      length(var.code_configuration.entry_point) >= 1 &&
      length(var.code_configuration.entry_point) <= 2 &&
      contains(["PYTHON_3_10", "PYTHON_3_11", "PYTHON_3_12", "PYTHON_3_13"], var.code_configuration.runtime)
    )
    error_message = "Code configuration must have 1-2 entry points and valid runtime (PYTHON_3_10, PYTHON_3_11, PYTHON_3_12, PYTHON_3_13)"
  }
}

# Container configuration (ECR-based deployment)
variable "container_configuration" {
  description = "Container configuration for ECR-based deployment. Exactly one of code_configuration or container_configuration must be specified"
  type = object({
    container_uri = string
  })
  default = null
}

# Network configuration
variable "vpc_config" {
  description = "VPC configuration for the AgentCore Runtime. If not provided, runtime will use PUBLIC network mode"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# Environment variables
variable "environment_variables" {
  description = "Map of environment variables to pass to the runtime"
  type        = map(string)
  default     = {}
}

# Authorization configuration
variable "authorizer_configuration" {
  description = "Authorization configuration for authenticating incoming requests"
  type = object({
    custom_jwt_authorizer = optional(object({
      discovery_url     = string
      allowed_audiences = optional(list(string))
      allowed_clients   = optional(list(string))
    }))
  })
  default = null
}

# Lifecycle configuration
variable "lifecycle_configuration" {
  description = "Runtime session and resource lifecycle configuration"
  type = object({
    idle_runtime_session_timeout = optional(number)
    max_lifetime                 = optional(number)
  })
  default = null
}

# Protocol configuration
variable "protocol_configuration" {
  description = "Protocol configuration for the runtime"
  type = object({
    server_protocol = string
  })
  default = null

  validation {
    condition     = var.protocol_configuration == null || try(contains(["HTTP", "MCP", "A2A"], var.protocol_configuration.server_protocol), false)
    error_message = "Server protocol must be HTTP, MCP, or A2A"
  }
}

# Request header configuration
variable "request_header_configuration" {
  description = "Configuration for HTTP request headers that will be passed through to the runtime"
  type = object({
    request_header_allowlist = list(string)
  })
  default = null
}

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    network = object({
      require_private_subnets = bool
      require_vpc_endpoints   = bool
      block_public_ingress    = bool
      require_imdsv2          = bool
    })
    compliance = object({
      enable_point_in_time_recovery = bool
      require_reserved_concurrency  = bool
      enable_deletion_protection    = bool
    })
    data_protection = object({
      require_versioning  = bool
      require_mfa_delete  = bool
      require_backup      = bool
      require_lifecycle   = bool
      block_public_access = bool
      require_replication = bool
    })
  })
  default = null
}

variable "security_control_overrides" {
  description = "Override specific security controls with documented justification"
  type = object({
    disable_vpc_requirement = optional(bool, false)
    justification           = optional(string, "")
  })
  default = {
    disable_vpc_requirement = false
    justification           = ""
  }
}
