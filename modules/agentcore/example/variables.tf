variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Name for the Bedrock agent"
  type        = string
  default     = "event-normalizer"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "model_id" {
  description = "Bedrock foundation model ID"
  type        = string
  default     = "anthropic.claude-3-opus-20240229-v1:0"
}

variable "instruction" {
  description = "Instructions for the Bedrock agent"
  type        = string
  default     = "You are an expert at parsing corporate actions event data from various formats (PDF, XML, CSV)."
}

variable "description" {
  description = "Description of the Bedrock agent"
  type        = string
  default     = "Event Normalizer Agent for Corporate Actions Orchestrator"
}

variable "idle_session_ttl_seconds" {
  description = "Idle session TTL in seconds"
  type        = number
  default     = 900
}

variable "agent_alias_name" {
  description = "Name for the agent alias"
  type        = string
  default     = "production"
}

variable "agent_alias_description" {
  description = "Description for the agent alias"
  type        = string
  default     = "Production version of Event Normalizer Agent"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Component = "EventNormalizer"
  }
}
