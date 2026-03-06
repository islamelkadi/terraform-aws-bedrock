# Bedrock Agent Module Outputs

output "agent_id" {
  description = "ID of the Bedrock agent"
  value       = aws_bedrockagent_agent.this.id
}

output "agent_arn" {
  description = "ARN of the Bedrock agent"
  value       = aws_bedrockagent_agent.this.agent_arn
}

output "agent_name" {
  description = "Name of the Bedrock agent"
  value       = aws_bedrockagent_agent.this.agent_name
}

output "agent_version" {
  description = "Version of the Bedrock agent"
  value       = aws_bedrockagent_agent.this.agent_version
}

output "agent_alias_id" {
  description = "ID of the agent alias"
  value       = aws_bedrockagent_agent_alias.this.agent_alias_id
}

output "agent_alias_arn" {
  description = "ARN of the agent alias"
  value       = aws_bedrockagent_agent_alias.this.agent_alias_arn
}

output "agent_alias_name" {
  description = "Name of the agent alias"
  value       = aws_bedrockagent_agent_alias.this.agent_alias_name
}

output "role_arn" {
  description = "ARN of the IAM role used by the Bedrock agent"
  value       = var.create_role ? module.agent_role[0].role_arn : var.role_arn
}

output "role_name" {
  description = "Name of the IAM role used by the Bedrock agent"
  value       = var.create_role ? module.agent_role[0].role_name : null
}

output "knowledge_base_association_id" {
  description = "ID of the knowledge base association"
  value       = var.knowledge_base_id != null ? aws_bedrockagent_agent_knowledge_base_association.this[0].id : null
}

output "action_group_ids" {
  description = "Map of action group names to their IDs"
  value       = { for k, v in aws_bedrockagent_agent_action_group.this : k => v.id }
}

output "tags" {
  description = "Tags applied to the Bedrock agent"
  value       = aws_bedrockagent_agent.this.tags
}
