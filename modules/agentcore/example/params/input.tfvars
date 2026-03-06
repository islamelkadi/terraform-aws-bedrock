namespace   = "example"
environment = "dev"
name        = "event-normalizer"
region      = "us-east-1"

model_id    = "anthropic.claude-3-opus-20240229-v1:0"
instruction = "You are an expert at parsing corporate actions event data from various formats (PDF, XML, CSV)."
description = "Event Normalizer Agent for Corporate Actions Orchestrator"

idle_session_ttl_seconds = 900

kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

agent_alias_name        = "production"
agent_alias_description = "Production version of Event Normalizer Agent"

tags = {
  Component = "EventNormalizer"
}
