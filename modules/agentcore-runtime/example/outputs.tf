# Outputs for AgentCore Runtime example

output "runtime_id" {
  description = "AgentCore Runtime ID"
  value       = module.agentcore_runtime.runtime_id
}

output "runtime_arn" {
  description = "AgentCore Runtime ARN"
  value       = module.agentcore_runtime.runtime_arn
}

output "runtime_name" {
  description = "AgentCore Runtime name"
  value       = module.agentcore_runtime.runtime_name
}

output "runtime_version" {
  description = "AgentCore Runtime version"
  value       = module.agentcore_runtime.runtime_version
}
