# Terraform AWS Bedrock Agent Module

Production-ready AWS Bedrock Agent module with comprehensive security controls, IAM role management, knowledge base integration, and action group support. Enables AI-powered automation with Claude and other foundation models.

## Table of Contents

- [Security Controls](#security-controls)
- [Features](#features)
- [Usage Examples](#usage-examples)
- [Requirements](#requirements)
- [Examples](#examples)

## Security Controls

This module implements security controls based on the metadata module's security policy. Controls can be selectively overridden with documented business justification.

### Available Security Control Overrides

| Override Flag | Control | Default | Common Use Case |
|--------------|---------|---------|-----------------|
| `disable_kms_requirement` | KMS Customer-Managed Encryption | `false` | Development agents with no sensitive data |

### Security Control Architecture

**Two-Layer Design:**
1. **Metadata Module** (Policy Layer): Defines security requirements based on environment
2. **Bedrock Agent Module** (Enforcement Layer): Validates configuration against policy

**Override Pattern:**
```hcl
security_control_overrides = {
  disable_kms_requirement = true
  justification = "Development agent, no sensitive data processed"
}
```

### Best Practices

1. **Production Agents**: Always use KMS customer-managed keys for encryption
2. **Development Agents**: Overrides acceptable for cost optimization with justification
3. **IAM Policies**: Follow least privilege principle for action group Lambda functions
4. **Audit Trail**: All overrides require `justification` field for compliance

## Features

- **Foundation Model Support**: Claude 3, Titan, Jurassic-2, Command, and Llama models
- **Knowledge Base Integration**: Connect to Bedrock knowledge bases for RAG
- **Action Groups**: Lambda-backed API integrations for agent capabilities
- **IAM Role Management**: Automatic role creation with least privilege policies
- **KMS Encryption**: Optional customer-managed key encryption
- **Agent Aliases**: Version management with aliases
- **Prompt Overrides**: Custom prompt templates and inference configuration
- **Consistent Naming**: Integration with metadata module for standardized resource naming

## Usage Examples

### Example 1: Basic Bedrock Agent

```hcl
module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata"
  
  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"
  region      = "us-east-1"
}

module "event_normalizer_agent" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/agentcore"
  
  namespace   = module.metadata.namespace
  environment = module.metadata.environment
  name        = "event-normalizer"
  region      = module.metadata.region
  
  description = "AI agent for normalizing corporate action events from multiple data sources"
  model_id    = "anthropic.claude-3-sonnet-20240229-v1:0"
  
  instruction = <<-EOT
    You are a corporate actions event normalizer. Your role is to:
    1. Parse corporate action announcements from TMX and CDS feeds
    2. Extract key information (event type, dates, ratios, eligibility)
    3. Normalize data into a consistent JSON schema
    4. Validate data completeness and accuracy
  EOT
  
  idle_session_ttl_seconds = 600
  kms_key_arn              = module.kms.key_arn
  
  security_controls = module.metadata.security_controls
  
  tags = module.metadata.tags
}
```

### Example 2: Agent with Knowledge Base and Action Groups

```hcl
module "orchestrator_agent" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/agentcore"
  
  namespace   = "example"
  environment = "prod"
  name        = "orchestrator"
  region      = "us-east-1"
  
  description = "Main orchestration agent for corporate actions processing"
  model_id    = "anthropic.claude-3-opus-20240229-v1:0"
  
  instruction = file("${path.module}/agent-instructions.txt")
  
  # Connect to knowledge base for documentation
  knowledge_base_id          = module.knowledge_base.id
  knowledge_base_state       = "ENABLED"
  knowledge_base_description = "Corporate actions processing documentation and procedures"
  
  # Action groups for Lambda integrations
  action_groups = [
    {
      action_group_name  = "position-scanner"
      description        = "Scan customer positions for affected securities"
      action_group_state = "ENABLED"
      lambda_arn         = module.scanner_lambda.arn
      api_schema = {
        s3_bucket = module.schemas_bucket.id
        s3_key    = "position-scanner-api.json"
        payload   = ""
      }
    },
    {
      action_group_name  = "notification-sender"
      description        = "Send customer notifications via email/SMS"
      action_group_state = "ENABLED"
      lambda_arn         = module.notifier_lambda.arn
      api_schema = {
        s3_bucket = module.schemas_bucket.id
        s3_key    = "notification-sender-api.json"
        payload   = ""
      }
    }
  ]
  
  kms_key_arn = module.kms.key_arn
  
  security_controls = module.metadata.security_controls
  
  tags = merge(
    module.metadata.tags,
    {
      Tier = "AI"
      Criticality = "High"
    }
  )
}
```

### Example 3: Development Agent with Custom IAM Policies

```hcl
module "test_agent" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/agentcore"
  
  namespace   = "example"
  environment = "dev"
  name        = "test-agent"
  region      = "us-east-1"
  
  description = "Development test agent"
  model_id    = "anthropic.claude-3-haiku-20240307-v1:0"
  
  instruction = "You are a test agent for development purposes."
  
  # Custom IAM policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
  
  inline_policies = {
    "dynamodb-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = module.test_table.arn
      }]
    })
  }
  
  security_controls = module.metadata.security_controls
  
  # Override for development
  security_control_overrides = {
    disable_kms_requirement = true
    justification = "Development agent, no sensitive data processed"
  }
  
  tags = module.metadata.tags
}
```

## Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles){:target="_blank"} module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| KMS encryption | Optional | Required | Required |
| IAM least privilege | Enforced | Enforced | Enforced |
| CloudWatch Logs | Optional | Required | Required |
| Knowledge base encryption | Optional | Required | Required |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_groups"></a> [action\_groups](#input\_action\_groups) | List of action groups to attach to the agent | <pre>list(object({<br/>    action_group_name  = string<br/>    description        = string<br/>    action_group_state = string<br/>    lambda_arn         = string<br/>    api_schema = object({<br/>      s3_bucket = string<br/>      s3_key    = string<br/>      payload   = string<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_agent_alias_description"></a> [agent\_alias\_description](#input\_agent\_alias\_description) | Description for the agent alias | `string` | `"Latest version of the agent"` | no |
| <a name="input_agent_alias_name"></a> [agent\_alias\_name](#input\_agent\_alias\_name) | Name for the agent alias | `string` | `"latest"` | no |
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | JSON-encoded assume role policy document for the agent role. Only used if create\_role is true | `string` | `null` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Whether to create an IAM role for the Bedrock agent | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Bedrock agent | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_idle_session_ttl_seconds"></a> [idle\_session\_ttl\_seconds](#input\_idle\_session\_ttl\_seconds) | Maximum time in seconds that an agent session can remain idle before it is closed | `number` | `600` | no |
| <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies) | Map of inline policy names to policy documents (JSON). Only used if create\_role is true | `map(string)` | `{}` | no |
| <a name="input_instruction"></a> [instruction](#input\_instruction) | Instructions for the agent describing its role and behavior | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for encryption. If not provided, uses AWS managed key | `string` | `null` | no |
| <a name="input_knowledge_base_description"></a> [knowledge\_base\_description](#input\_knowledge\_base\_description) | Description of the knowledge base association | `string` | `"Knowledge base for agent context and documentation"` | no |
| <a name="input_knowledge_base_id"></a> [knowledge\_base\_id](#input\_knowledge\_base\_id) | ID of the Bedrock knowledge base to associate with the agent. Set to null to disable | `string` | `null` | no |
| <a name="input_knowledge_base_state"></a> [knowledge\_base\_state](#input\_knowledge\_base\_state) | State of the knowledge base association (ENABLED or DISABLED) | `string` | `"ENABLED"` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of AWS managed policy ARNs to attach to the agent role. Only used if create\_role is true | `list(string)` | `[]` | no |
| <a name="input_model_id"></a> [model\_id](#input\_model\_id) | Foundation model ID for the agent (e.g., anthropic.claude-3-opus-20240229-v1:0) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Bedrock agent | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_prompt_override_configuration"></a> [prompt\_override\_configuration](#input\_prompt\_override\_configuration) | Configuration for overriding default prompts | <pre>object({<br/>    prompt_type          = string<br/>    prompt_state         = string<br/>    base_prompt_template = string<br/>    inference_configuration = object({<br/>      temperature    = number<br/>      top_p          = number<br/>      top_k          = number<br/>      max_length     = number<br/>      stop_sequences = list(string)<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of the IAM role for the Bedrock agent. If not provided, a role will be created | `string` | `null` | no |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls with documented justification | <pre>object({<br/>    disable_kms_requirement = optional(bool, false)<br/>    justification           = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_kms_requirement": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>    data_protection = object({<br/>      require_versioning  = bool<br/>      require_mfa_delete  = bool<br/>      require_backup      = bool<br/>      require_lifecycle   = bool<br/>      block_public_access = bool<br/>      require_replication = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_ids"></a> [action\_group\_ids](#output\_action\_group\_ids) | Map of action group names to their IDs |
| <a name="output_agent_alias_arn"></a> [agent\_alias\_arn](#output\_agent\_alias\_arn) | ARN of the agent alias |
| <a name="output_agent_alias_id"></a> [agent\_alias\_id](#output\_agent\_alias\_id) | ID of the agent alias |
| <a name="output_agent_alias_name"></a> [agent\_alias\_name](#output\_agent\_alias\_name) | Name of the agent alias |
| <a name="output_agent_arn"></a> [agent\_arn](#output\_agent\_arn) | ARN of the Bedrock agent |
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | ID of the Bedrock agent |
| <a name="output_agent_name"></a> [agent\_name](#output\_agent\_name) | Name of the Bedrock agent |
| <a name="output_agent_version"></a> [agent\_version](#output\_agent\_version) | Version of the Bedrock agent |
| <a name="output_knowledge_base_association_id"></a> [knowledge\_base\_association\_id](#output\_knowledge\_base\_association\_id) | ID of the knowledge base association |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role used by the Bedrock agent |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role used by the Bedrock agent |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the Bedrock agent |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->

## Examples

See [example/](example/) for a complete working example.

