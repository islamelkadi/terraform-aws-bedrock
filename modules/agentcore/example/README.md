# Basic Bedrock Agent Example

This example creates a Bedrock agent with a production alias using a fictitious KMS key ARN.

## Usage

```bash
terraform init
terraform plan -var-file=params/input.tfvars
terraform apply -var-file=params/input.tfvars
```

## What This Example Creates

- Bedrock Agent with Claude 3 Opus model
- IAM role for the agent
- Agent alias for production use
- KMS encryption for agent data

## Clean Up

```bash
terraform destroy -var-file=params/input.tfvars
```

<!-- BEGIN_TF_DOCS -->
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
| <a name="module_bedrock_agent"></a> [bedrock\_agent](#module\_bedrock\_agent) | ../ | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | git::https://github.com/islamelkadi/terraform-aws-kms.git | v1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_alias_description"></a> [agent\_alias\_description](#input\_agent\_alias\_description) | Description for the agent alias | `string` | `"Production version of Event Normalizer Agent"` | no |
| <a name="input_agent_alias_name"></a> [agent\_alias\_name](#input\_agent\_alias\_name) | Name for the agent alias | `string` | `"production"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Bedrock agent | `string` | `"Event Normalizer Agent for Corporate Actions Orchestrator"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_idle_session_ttl_seconds"></a> [idle\_session\_ttl\_seconds](#input\_idle\_session\_ttl\_seconds) | Idle session TTL in seconds | `number` | `900` | no |
| <a name="input_instruction"></a> [instruction](#input\_instruction) | Instructions for the Bedrock agent | `string` | `"You are an expert at parsing corporate actions event data from various formats (PDF, XML, CSV)."` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for encryption | `string` | `"arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"` | no |
| <a name="input_model_id"></a> [model\_id](#input\_model\_id) | Bedrock foundation model ID | `string` | `"anthropic.claude-3-opus-20240229-v1:0"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Bedrock agent | `string` | `"event-normalizer"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | `"example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | <pre>{<br/>  "Component": "EventNormalizer"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_alias_id"></a> [agent\_alias\_id](#output\_agent\_alias\_id) | ID of the agent alias |
| <a name="output_agent_arn"></a> [agent\_arn](#output\_agent\_arn) | ARN of the Bedrock agent |
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | ID of the Bedrock agent |
<!-- END_TF_DOCS -->
