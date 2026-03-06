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
  description = "Name for the AgentCore Runtime"
  type        = string
  default     = "corporate-actions"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "description" {
  description = "Description of the AgentCore Runtime"
  type        = string
  default     = "AgentCore Runtime for corporate actions processing"
}

variable "role_arn" {
  description = "IAM role ARN for runtime execution"
  type        = string
  default     = "arn:aws:iam::123456789012:role/agentcore-runtime-role"
}

variable "s3_bucket" {
  description = "S3 bucket for code deployment"
  type        = string
  default     = "my-agentcore-code"
}

variable "s3_key" {
  description = "S3 key for the runtime code archive"
  type        = string
  default     = "runtime/app.zip"
}

variable "subnet_ids" {
  description = "List of private subnet IDs for VPC configuration"
  type        = list(string)
  default     = ["subnet-0a1b2c3d4e5f00001", "subnet-0a1b2c3d4e5f00002"]
}

variable "security_group_ids" {
  description = "List of security group IDs for VPC configuration"
  type        = list(string)
  default     = ["sg-0a1b2c3d4e5f67890"]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Example   = "AGENTCORE_RUNTIME"
    Component = "AGENT_CORE"
  }
}
