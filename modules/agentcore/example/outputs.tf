# Example Outputs

output "agent_id" {
  description = "ID of the Bedrock agent"
  value       = module.bedrock_agent.agent_id
}

output "agent_arn" {
  description = "ARN of the Bedrock agent"
  value       = module.bedrock_agent.agent_arn
}

output "agent_alias_id" {
  description = "ID of the agent alias"
  value       = module.bedrock_agent.agent_alias_id
}
