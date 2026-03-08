# Terraform AWS Bedrock AgentCore Runtime Module

Purpose-built serverless runtime for deploying and scaling AI agents using any open-source framework.

## Features

- **Serverless Execution**: No infrastructure management required
- **Extended Runtime**: Up to 8 hours execution time (vs Lambda's 15 minutes)
- **Consumption-Based Pricing**: Pay only for actual compute used
- **Built-in Observability**: Agent-specific tracing and monitoring
- **Framework Agnostic**: Works with LangGraph, CrewAI, Strands Agents, and more
- **VPC Support**: Deploy in private subnets for enhanced security
- **Code or Container Deployment**: Deploy from S3 (Python code) or ECR (containers)

## Security

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| VPC deployment | Optional | Recommended | Required |
| IAM least privilege | Enforced | Enforced | Enforced |
| CloudWatch Logs | Optional | Required | Required |
| JWT authorization | Optional | Recommended | Required |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.

## Usage

### Basic Usage with Code Deployment (S3)

```hcl
module "agentcore_runtime" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/agentcore-runtime"

  namespace   = "example"
  environment = "dev"
  name        = "corporate-actions-agent"
  region      = "us-east-1"

  description = "AgentCore Runtime for corporate actions processing"
  role_arn    = aws_iam_role.agentcore_runtime.arn

  # Code deployment from S3
  code_configuration = {
    entry_point   = ["main.py"]
    runtime       = "PYTHON_3_13"
    s3_bucket     = "my-code-bucket"
    s3_key        = "agentcore_runtime.zip"
    s3_version_id = null # Optional: use specific version
  }

  # VPC configuration for private deployment
  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [aws_security_group.agentcore_runtime.id]
  }

  # Environment variables
  environment_variables = {
    LOG_LEVEL              = "INFO"
    EVENTS_TABLE_NAME      = "corporate-actions-events"
    POSITIONS_DB_ENDPOINT  = "db.example.com"
  }

  tags = {
    Application = "CorporateActions"
    ManagedBy   = "Terraform"
  }
}
```

### Container Deployment (ECR)

```hcl
module "agentcore_runtime" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/agentcore-runtime"

  namespace   = "example"
  environment = "prod"
  name        = "trading-agent"
  region      = "us-east-1"

  role_arn = aws_iam_role.agentcore_runtime.arn

  # Container deployment from ECR
  container_configuration = {
    container_uri = "${aws_ecr_repository.agent.repository_url}:latest"
  }

  # Public network mode (no VPC)
  vpc_config = null

  environment_variables = {
    ENV = "production"
  }

  tags = {
    Application = "Trading"
  }
}
```

### With JWT Authorization

```hcl
module "agentcore_runtime" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/agentcore-runtime"

  namespace   = "example"
  environment = "prod"
  name        = "customer-service-agent"
  region      = "us-east-1"

  role_arn = aws_iam_role.agentcore_runtime.arn

  code_configuration = {
    entry_point = ["main.py"]
    runtime     = "PYTHON_3_13"
    s3_bucket   = "agent-code"
    s3_key      = "customer-service.zip"
  }

  # JWT authorization
  authorizer_configuration = {
    custom_jwt_authorizer = {
      discovery_url     = "https://auth.example.com/.well-known/openid-configuration"
      allowed_audiences = ["customer-app", "mobile-app"]
      allowed_clients   = ["client-123", "client-456"]
    }
  }

  # MCP protocol
  protocol_configuration = {
    server_protocol = "MCP"
  }

  vpc_config = null

  tags = {
    Application = "CustomerService"
  }
}
```

### With Lifecycle Configuration

```hcl
module "agentcore_runtime" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/agentcore-runtime"

  namespace   = "example"
  environment = "dev"
  name        = "research-agent"
  region      = "us-east-1"

  role_arn = aws_iam_role.agentcore_runtime.arn

  code_configuration = {
    entry_point = ["main.py"]
    runtime     = "PYTHON_3_13"
    s3_bucket   = "agent-code"
    s3_key      = "research.zip"
  }

  # Lifecycle configuration
  lifecycle_configuration = {
    idle_runtime_session_timeout = 600  # 10 minutes
    max_lifetime                 = 28800 # 8 hours
  }

  vpc_config = null

  tags = {
    Application = "Research"
  }
}
```

## IAM Role Requirements

The IAM role must have permissions for:

1. **Bedrock Model Invocation** (if using Bedrock models):
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "bedrock:InvokeModel",
       "bedrock:InvokeModelWithResponseStream"
     ],
     "Resource": "arn:aws:bedrock:*::foundation-model/*"
   }
   ```

2. **S3 Access** (for code deployment):
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "s3:GetObject"
     ],
     "Resource": "arn:aws:s3:::your-code-bucket/*"
   }
   ```

3. **CloudWatch Logs**:
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:log-group:/aws/bedrock/agentcore/runtime/*"
   }
   ```

4. **VPC Access** (if using VPC):
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "ec2:CreateNetworkInterface",
       "ec2:DescribeNetworkInterfaces",
       "ec2:DeleteNetworkInterface"
     ],
     "Resource": "*"
   }
   ```

## Security Best Practices

1. **Use VPC Deployment**: Deploy in private subnets for enhanced security
2. **Least Privilege IAM**: Grant only required permissions
3. **Environment Variables**: Use Secrets Manager for sensitive data, not environment variables
4. **Authorization**: Enable JWT authorization for production workloads
5. **Monitoring**: Enable CloudWatch Logs and X-Ray tracing
6. **Code Versioning**: Use S3 versioning for code artifacts

## Network Modes

### PUBLIC Mode
- Runtime accessible from internet
- No VPC configuration required
- Suitable for public APIs and webhooks

### VPC Mode
- Runtime deployed in private subnets
- Requires VPC configuration (subnets + security groups)
- Suitable for internal applications and sensitive workloads

## Supported Runtimes

- `PYTHON_3_10`
- `PYTHON_3_11`
- `PYTHON_3_12`
- `PYTHON_3_13`

## Supported Protocols

- `HTTP` - Standard HTTP protocol
- `MCP` - Model Context Protocol
- `A2A` - Agent-to-Agent protocol

## References

- [Amazon Bedrock AgentCore Runtime Documentation](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/agents-tools-runtime.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_agent_runtime)

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
# Primary Module Example - This demonstrates the terraform-aws-bedrock agentcore-runtime module
# Supporting infrastructure (VPC) is defined in separate files
# to keep this example focused on the module's core functionality.
#
# Basic AgentCore Runtime Example

module "agentcore_runtime" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description
  role_arn    = var.role_arn

  code_configuration = {
    entry_point = ["app.py", "handler"]
    runtime     = "PYTHON_3_13"
    s3_bucket   = var.s3_bucket
    s3_key      = var.s3_key
  }

  # Direct reference to vpc.tf module outputs
  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.security_group.security_group_id]
  }

  environment_variables = {
    LOG_LEVEL           = "INFO"
    DYNAMODB_TABLE_NAME = "corporate-actions"
  }

  tags = var.tags
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagentcore_agent_runtime.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_agent_runtime) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorizer_configuration"></a> [authorizer\_configuration](#input\_authorizer\_configuration) | Authorization configuration for authenticating incoming requests | <pre>object({<br/>    custom_jwt_authorizer = optional(object({<br/>      discovery_url     = string<br/>      allowed_audiences = optional(list(string))<br/>      allowed_clients   = optional(list(string))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_code_configuration"></a> [code\_configuration](#input\_code\_configuration) | Code configuration for S3-based deployment. Exactly one of code\_configuration or container\_configuration must be specified | <pre>object({<br/>    entry_point   = list(string)<br/>    runtime       = string<br/>    s3_bucket     = string<br/>    s3_key        = string<br/>    s3_version_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_container_configuration"></a> [container\_configuration](#input\_container\_configuration) | Container configuration for ECR-based deployment. Exactly one of code\_configuration or container\_configuration must be specified | <pre>object({<br/>    container_uri = string<br/>  })</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the AgentCore Runtime | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Map of environment variables to pass to the runtime | `map(string)` | `{}` | no |
| <a name="input_lifecycle_configuration"></a> [lifecycle\_configuration](#input\_lifecycle\_configuration) | Runtime session and resource lifecycle configuration | <pre>object({<br/>    idle_runtime_session_timeout = optional(number)<br/>    max_lifetime                 = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the AgentCore Runtime | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_protocol_configuration"></a> [protocol\_configuration](#input\_protocol\_configuration) | Protocol configuration for the runtime | <pre>object({<br/>    server_protocol = string<br/>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_request_header_configuration"></a> [request\_header\_configuration](#input\_request\_header\_configuration) | Configuration for HTTP request headers that will be passed through to the runtime | <pre>object({<br/>    request_header_allowlist = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of the IAM role that the AgentCore Runtime assumes to access AWS services | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls with documented justification | <pre>object({<br/>    disable_vpc_requirement = optional(bool, false)<br/>    justification           = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_vpc_requirement": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>    data_protection = object({<br/>      require_versioning  = bool<br/>      require_mfa_delete  = bool<br/>      require_backup      = bool<br/>      require_lifecycle   = bool<br/>      block_public_access = bool<br/>      require_replication = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration for the AgentCore Runtime. If not provided, runtime will use PUBLIC network mode | <pre>object({<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_runtime_arn"></a> [runtime\_arn](#output\_runtime\_arn) | ARN of the AgentCore Runtime |
| <a name="output_runtime_id"></a> [runtime\_id](#output\_runtime\_id) | Unique identifier of the AgentCore Runtime |
| <a name="output_runtime_name"></a> [runtime\_name](#output\_runtime\_name) | Name of the AgentCore Runtime |
| <a name="output_runtime_version"></a> [runtime\_version](#output\_runtime\_version) | Version of the AgentCore Runtime |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the AgentCore Runtime |
| <a name="output_workload_identity_arn"></a> [workload\_identity\_arn](#output\_workload\_identity\_arn) | ARN of the workload identity |
| <a name="output_workload_identity_details"></a> [workload\_identity\_details](#output\_workload\_identity\_details) | Workload identity details for the runtime |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
