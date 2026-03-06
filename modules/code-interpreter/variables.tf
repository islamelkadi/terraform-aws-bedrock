# Bedrock AgentCore Code Interpreter Module Variables

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
  description = "Name of the Code Interpreter"
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

# Code Interpreter configuration
variable "description" {
  description = "Description of the Code Interpreter"
  type        = string
  default     = ""
}

variable "network_mode" {
  description = "Network mode for the Code Interpreter. Valid values: PUBLIC, SANDBOX, VPC"
  type        = string
  default     = "SANDBOX"

  validation {
    condition     = contains(["PUBLIC", "SANDBOX", "VPC"], var.network_mode)
    error_message = "Network mode must be PUBLIC, SANDBOX, or VPC"
  }
}

variable "execution_role_arn" {
  description = "ARN of the IAM role that the Code Interpreter assumes. Required for SANDBOX mode"
  type        = string
}

# VPC configuration (only for VPC mode)
variable "vpc_config" {
  description = "VPC configuration for the Code Interpreter. Required when network_mode is VPC"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "security_control_overrides" {
  description = "Override specific security controls with documented justification"
  type = object({
    disable_sandbox_requirement = optional(bool, false)
    justification               = optional(string, "")
  })
  default = {
    disable_sandbox_requirement = false
    justification               = ""
  }
}
