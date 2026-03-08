# Bedrock Agent Module - Primary Resource Definitions

# IAM Policy Documents for Agent Role
data "aws_iam_policy_document" "bedrock_invoke" {
  count = var.create_role ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = [
      "arn:aws:bedrock:${var.region}::foundation-model/${var.model_id}"
    ]
  }
}

data "aws_iam_policy_document" "knowledge_base" {
  count = var.create_role && var.knowledge_base_id != null ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "bedrock:Retrieve",
      "bedrock:RetrieveAndGenerate"
    ]
    resources = [
      "arn:aws:bedrock:${var.region}:*:knowledge-base/${var.knowledge_base_id}"
    ]
  }
}

# IAM Role for Bedrock Agent
# IAM Role for Bedrock Agent (if create_role is true)
resource "aws_iam_role" "agent" {
  count = var.create_role ? 1 : 0
  
  name = "${module.metadata.resource_prefix}-bedrock-agent"
  
  assume_role_policy = var.assume_role_policy != null ? var.assume_role_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = merge(
    module.metadata.security_tags,
    var.tags,
    {
      Name = "${module.metadata.resource_prefix}-bedrock-agent"
    }
  )
}

# Attach managed policies to the role
resource "aws_iam_role_policy_attachment" "agent_managed" {
  for_each = var.create_role ? toset(var.managed_policy_arns) : []
  
  role       = aws_iam_role.agent[0].name
  policy_arn = each.value
}

# Attach inline policies to the role
resource "aws_iam_role_policy" "agent_inline" {
  for_each = var.create_role ? local.inline_policies : {}
  
  name   = each.key
  role   = aws_iam_role.agent[0].id
  policy = each.value
}

# Bedrock Agent
resource "aws_bedrockagent_agent" "this" {
  agent_name              = local.agent_name
  agent_resource_role_arn = var.create_role ? aws_iam_role.agent[0].arn : var.role_arn
  foundation_model        = var.model_id
  instruction             = var.instruction
  description             = var.description

  idle_session_ttl_in_seconds = var.idle_session_ttl_seconds

  customer_encryption_key_arn = var.kms_key_arn

  prompt_override_configuration = var.prompt_override_configuration != null ? [
    {
      override_lambda = null
      prompt_configurations = [
        {
          prompt_type          = var.prompt_override_configuration.prompt_type
          prompt_state         = var.prompt_override_configuration.prompt_state
          prompt_creation_mode = "OVERRIDDEN"
          parser_mode          = "DEFAULT"
          base_prompt_template = var.prompt_override_configuration.base_prompt_template
          inference_configuration = [
            {
              temperature    = var.prompt_override_configuration.inference_configuration.temperature
              top_p          = var.prompt_override_configuration.inference_configuration.top_p
              top_k          = var.prompt_override_configuration.inference_configuration.top_k
              max_length     = var.prompt_override_configuration.inference_configuration.max_length
              stop_sequences = var.prompt_override_configuration.inference_configuration.stop_sequences
            }
          ]
        }
      ]
    }
  ] : null

  tags = local.tags
}

# Agent Alias
resource "aws_bedrockagent_agent_alias" "this" {
  agent_id         = aws_bedrockagent_agent.this.id
  agent_alias_name = var.agent_alias_name
  description      = var.agent_alias_description

  tags = local.tags
}

# Knowledge Base Association
resource "aws_bedrockagent_agent_knowledge_base_association" "this" {
  count = var.knowledge_base_id != null ? 1 : 0

  agent_id             = aws_bedrockagent_agent.this.id
  knowledge_base_id    = var.knowledge_base_id
  knowledge_base_state = var.knowledge_base_state
  description          = var.knowledge_base_description
}

# Action Groups
resource "aws_bedrockagent_agent_action_group" "this" {
  for_each = { for ag in var.action_groups : ag.action_group_name => ag }

  agent_id           = aws_bedrockagent_agent.this.id
  agent_version      = "DRAFT"
  action_group_name  = each.value.action_group_name
  description        = each.value.description
  action_group_state = each.value.action_group_state

  action_group_executor {
    lambda = each.value.lambda_arn
  }

  dynamic "api_schema" {
    for_each = each.value.api_schema.payload != null ? [each.value.api_schema] : []
    content {
      payload = api_schema.value.payload
    }
  }

  dynamic "api_schema" {
    for_each = each.value.api_schema.s3_bucket != null && each.value.api_schema.payload == null ? [each.value.api_schema] : []
    content {
      s3 {
        s3_bucket_name = api_schema.value.s3_bucket
        s3_object_key  = api_schema.value.s3_key
      }
    }
  }
}
