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
  description = "Name for the Code Interpreter"
  type        = string
  default     = "data-analysis"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "description" {
  description = "Description of the Code Interpreter"
  type        = string
  default     = "Code Interpreter for data analysis tasks"
}

variable "network_mode" {
  description = "Network mode (SANDBOX, VPC, PUBLIC)"
  type        = string
  default     = "SANDBOX"
}

variable "execution_role_arn" {
  description = "IAM role ARN for code execution"
  type        = string
  default     = "arn:aws:iam::123456789012:role/code-interpreter-role"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Example = "CODE_INTERPRETER"
    Purpose = "DATA_ANALYSIS"
  }
}
