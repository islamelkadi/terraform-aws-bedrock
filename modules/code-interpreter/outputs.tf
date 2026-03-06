# Bedrock AgentCore Code Interpreter Module Outputs

output "code_interpreter_id" {
  description = "Unique identifier of the Code Interpreter"
  value       = aws_bedrockagentcore_code_interpreter.this.code_interpreter_id
}

output "code_interpreter_arn" {
  description = "ARN of the Code Interpreter"
  value       = aws_bedrockagentcore_code_interpreter.this.code_interpreter_arn
}

output "code_interpreter_name" {
  description = "Name of the Code Interpreter"
  value       = aws_bedrockagentcore_code_interpreter.this.name
}

output "network_mode" {
  description = "Network mode of the Code Interpreter"
  value       = var.vpc_config != null ? "VPC" : "PUBLIC"
}

output "execution_role_arn" {
  description = "ARN of the Code Interpreter execution role"
  value       = var.execution_role_arn
}

output "tags" {
  description = "Tags applied to the Code Interpreter"
  value       = local.tags
}
