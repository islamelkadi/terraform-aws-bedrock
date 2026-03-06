# Bedrock Agent Module Variables

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
  description = "Name of the Bedrock agent"
  type        = string
}

variable "attributes" {
  description = "Additional attributes for naming"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to use between name components"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Bedrock agent configuration
variable "description" {
  description = "Description of the Bedrock agent"
  type        = string
  default     = ""
}

variable "model_id" {
  description = "Foundation model ID for the agent (e.g., anthropic.claude-3-opus-20240229-v1:0)"
  type        = string

  validation {
    condition     = can(regex("^(anthropic\\.claude|amazon\\.titan|ai21\\.j2|cohere\\.command|meta\\.llama)", var.model_id))
    error_message = "Model ID must be a valid Bedrock foundation model identifier"
  }
}

variable "instruction" {
  description = "Instructions for the agent describing its role and behavior"
  type        = string
}

variable "idle_session_ttl_seconds" {
  description = "Maximum time in seconds that an agent session can remain idle before it is closed"
  type        = number
  default     = 600

  validation {
    condition     = var.idle_session_ttl_seconds >= 60 && var.idle_session_ttl_seconds <= 3600
    error_message = "Idle session TTL must be between 60 and 3600 seconds"
  }
}

# IAM role
variable "role_arn" {
  description = "ARN of the IAM role for the Bedrock agent. If not provided, a role will be created"
  type        = string
  default     = null
}

variable "create_role" {
  description = "Whether to create an IAM role for the Bedrock agent"
  type        = bool
  default     = true
}

variable "assume_role_policy" {
  description = "JSON-encoded assume role policy document for the agent role. Only used if create_role is true"
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the agent role. Only used if create_role is true"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to policy documents (JSON). Only used if create_role is true"
  type        = map(string)
  default     = {}
}

# Knowledge base configuration
variable "knowledge_base_id" {
  description = "ID of the Bedrock knowledge base to associate with the agent. Set to null to disable"
  type        = string
  default     = null
}

variable "knowledge_base_state" {
  description = "State of the knowledge base association (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.knowledge_base_state)
    error_message = "Knowledge base state must be ENABLED or DISABLED"
  }
}

variable "knowledge_base_description" {
  description = "Description of the knowledge base association"
  type        = string
  default     = "Knowledge base for agent context and documentation"
}

# Action groups configuration
variable "action_groups" {
  description = "List of action groups to attach to the agent"
  type = list(object({
    action_group_name  = string
    description        = string
    action_group_state = string
    lambda_arn         = string
    api_schema = object({
      s3_bucket = string
      s3_key    = string
      payload   = string
    })
  }))
  default = []

  validation {
    condition = alltrue([
      for ag in var.action_groups : contains(["ENABLED", "DISABLED"], ag.action_group_state)
    ])
    error_message = "Action group state must be ENABLED or DISABLED"
  }
}

# Encryption
variable "kms_key_arn" {
  description = "ARN of KMS key for encryption. If not provided, uses AWS managed key"
  type        = string
  default     = null
}

# Prompt override configuration
variable "prompt_override_configuration" {
  description = "Configuration for overriding default prompts"
  type = object({
    prompt_type          = string
    prompt_state         = string
    base_prompt_template = string
    inference_configuration = object({
      temperature    = number
      top_p          = number
      top_k          = number
      max_length     = number
      stop_sequences = list(string)
    })
  })
  default = null
}

# Agent alias configuration
variable "agent_alias_name" {
  description = "Name for the agent alias"
  type        = string
  default     = "latest"
}

variable "agent_alias_description" {
  description = "Description for the agent alias"
  type        = string
  default     = "Latest version of the agent"
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
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
    disable_kms_requirement = optional(bool, false)
    justification           = optional(string, "")
  })
  default = {
    disable_kms_requirement = false
    justification           = ""
  }
}
