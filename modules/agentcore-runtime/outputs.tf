# Bedrock AgentCore Runtime Module Outputs

output "runtime_id" {
  description = "Unique identifier of the AgentCore Runtime"
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_id
}

output "runtime_arn" {
  description = "ARN of the AgentCore Runtime"
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_arn
}

output "runtime_name" {
  description = "Name of the AgentCore Runtime"
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_name
}

output "runtime_version" {
  description = "Version of the AgentCore Runtime"
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_version
}

output "workload_identity_details" {
  description = "Workload identity details for the runtime"
  value       = aws_bedrockagentcore_agent_runtime.this.workload_identity_details
}

output "workload_identity_arn" {
  description = "ARN of the workload identity"
  value       = length(aws_bedrockagentcore_agent_runtime.this.workload_identity_details) > 0 ? aws_bedrockagentcore_agent_runtime.this.workload_identity_details[0].workload_identity_arn : null
}

output "tags" {
  description = "Tags applied to the AgentCore Runtime"
  value       = aws_bedrockagentcore_agent_runtime.this.tags
}
