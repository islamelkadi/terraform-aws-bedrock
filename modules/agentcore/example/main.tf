# Basic Bedrock Agent Example

module "bedrock_agent" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  model_id    = var.model_id
  instruction = var.instruction
  description = var.description

  idle_session_ttl_seconds = var.idle_session_ttl_seconds

  kms_key_arn = var.kms_key_arn

  agent_alias_name        = var.agent_alias_name
  agent_alias_description = var.agent_alias_description

  tags = var.tags
}
