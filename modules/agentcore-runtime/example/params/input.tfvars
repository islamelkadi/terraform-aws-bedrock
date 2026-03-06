namespace   = "example"
environment = "dev"
name        = "corporate-actions"
region      = "us-east-1"

description = "AgentCore Runtime for corporate actions processing"
role_arn    = "arn:aws:iam::123456789012:role/agentcore-runtime-role"

s3_bucket = "my-agentcore-code"
s3_key    = "runtime/app.zip"

subnet_ids         = ["subnet-0a1b2c3d4e5f00001", "subnet-0a1b2c3d4e5f00002"]
security_group_ids = ["sg-0a1b2c3d4e5f67890"]

tags = {
  Example   = "AGENTCORE_RUNTIME"
  Component = "AGENT_CORE"
}
