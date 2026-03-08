# Basic AgentCore Runtime Example

This example creates an AgentCore Runtime with S3-based Python code deployment and VPC integration using fictitious ARNs.

## Usage

```bash
terraform init
terraform plan -var-file=params/input.tfvars
terraform apply -var-file=params/input.tfvars
```

## What This Example Creates

- AgentCore Runtime with Python 3.13
- S3-based code deployment
- VPC integration for private network access

## Prerequisites

- Existing IAM role for runtime execution
- S3 bucket with runtime code archive
- VPC with private subnets and security group

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
| <a name="module_agentcore_runtime"></a> [agentcore\_runtime](#module\_agentcore\_runtime) | ../ | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | git::https://github.com/islamelkadi/terraform-aws-vpc.git//modules/security-group | v1.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/islamelkadi/terraform-aws-vpc.git//modules/vpc | v1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the AgentCore Runtime | `string` | `"AgentCore Runtime for corporate actions processing"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the AgentCore Runtime | `string` | `"corporate-actions"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | `"example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | IAM role ARN for runtime execution | `string` | `"arn:aws:iam::123456789012:role/agentcore-runtime-role"` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket for code deployment | `string` | `"my-agentcore-code"` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key for the runtime code archive | `string` | `"runtime/app.zip"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs for VPC configuration | `list(string)` | <pre>[<br/>  "sg-0a1b2c3d4e5f67890"<br/>]</pre> | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of private subnet IDs for VPC configuration | `list(string)` | <pre>[<br/>  "subnet-0a1b2c3d4e5f00001",<br/>  "subnet-0a1b2c3d4e5f00002"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | <pre>{<br/>  "Component": "AGENT_CORE",<br/>  "Example": "AGENTCORE_RUNTIME"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_runtime_arn"></a> [runtime\_arn](#output\_runtime\_arn) | AgentCore Runtime ARN |
| <a name="output_runtime_id"></a> [runtime\_id](#output\_runtime\_id) | AgentCore Runtime ID |
| <a name="output_runtime_name"></a> [runtime\_name](#output\_runtime\_name) | AgentCore Runtime name |
| <a name="output_runtime_version"></a> [runtime\_version](#output\_runtime\_version) | AgentCore Runtime version |
<!-- END_TF_DOCS -->
