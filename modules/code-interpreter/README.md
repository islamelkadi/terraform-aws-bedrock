# Terraform AWS Bedrock Code Interpreter Module

Terraform module for deploying Amazon Bedrock AgentCore Code Interpreter - a secure Python code execution environment for AI agents to perform dynamic calculations.

## Features

- Secure sandboxed Python code execution
- Three network modes: PUBLIC, SANDBOX (recommended), VPC
- IAM role-based execution permissions
- Integrated with AgentCore Runtime for seamless agent workflows
- Security controls with override system

## Security

### Security Controls

This module implements security controls with an override system:

```hcl
module "code_interpreter" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/code-interpreter"

  # ... other configuration ...

  # Override security controls (requires justification)
  security_control_overrides = {
    disable_sandbox_requirement = true
    justification               = "Development environment - PUBLIC mode for testing"
  }
}
```

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| SANDBOX network mode | Optional | Recommended | Required |
| IAM least privilege | Enforced | Enforced | Enforced |
| VPC deployment (if not SANDBOX) | Optional | Recommended | Required |
| CloudWatch Logs | Optional | Required | Required |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.
## Usage

### Basic Example (SANDBOX mode - recommended)

```hcl
module "code_interpreter" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/code-interpreter"

  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions-code-interpreter"
  region      = "us-east-1"

  description = "Code Interpreter for dynamic corporate actions calculations"

  # SANDBOX mode (recommended) - isolated execution environment
  network_mode       = "SANDBOX"
  execution_role_arn = aws_iam_role.code_interpreter.arn

  tags = {
    Domain  = "CorporateEvents"
    Purpose = "CodeInterpreter"
  }
}
```

### VPC Mode Example

```hcl
module "code_interpreter" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/code-interpreter"

  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions-code-interpreter"
  region      = "us-east-1"

  description = "Code Interpreter for dynamic corporate actions calculations"

  # VPC mode - for private network access
  network_mode       = "VPC"
  execution_role_arn = aws_iam_role.code_interpreter.arn

  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [aws_security_group.code_interpreter.id]
  }

  tags = {
    Domain  = "CorporateEvents"
    Purpose = "CodeInterpreter"
  }
}
```

## When to Use Code Interpreter

Use Code Interpreter when your AI agent needs to:

1. **Perform dynamic calculations** on complex or unprecedented events
   - Example: "Reverse split with cash-in-lieu for fractional shares"
   - AI can write Python code to calculate exact share quantities

2. **Handle mathematical edge cases** that traditional code doesn't cover
   - Example: Fractional shares, rounding rules, tax calculations
   - AI generates code on-the-fly for specific scenarios

3. **Validate complex business logic** before execution
   - Example: Multi-step corporate actions with dependencies
   - AI can simulate outcomes before committing changes

## Network Modes

Code Interpreter supports three network modes, each with different capabilities and security profiles:

### PUBLIC Mode
**Description**: Code executes with full internet access

**Capabilities**:
- ✅ Call external APIs
- ✅ Download Python packages from PyPI
- ✅ Access public internet resources
- ❌ Cannot access VPC resources (RDS, DynamoDB)

**Security**: Low - Code can make arbitrary network requests

**Use Cases**:
- Development and testing
- Calling external APIs (weather, stock prices, etc.)
- Installing packages dynamically
- Prototyping

**Example**:
```hcl
module "code_interpreter" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/code-interpreter"
  
  network_mode       = "PUBLIC"
  execution_role_arn = aws_iam_role.code_interpreter.arn
  
  # No VPC configuration needed
}
```

---

### SANDBOX Mode (Most Secure)
**Description**: Completely isolated execution environment with NO network access

**Capabilities**:
- ✅ Execute Python code with pre-installed packages
- ✅ Perform calculations and data transformations
- ✅ Maximum security isolation
- ❌ Cannot access internet
- ❌ Cannot access VPC resources
- ❌ Cannot download packages

**Security**: High - Complete isolation, no network access

**Use Cases**:
- Pure mathematical calculations
- Data transformations on data passed from AgentCore Runtime
- Untrusted code execution
- Compliance requirements for isolated execution

**Example**:
```hcl
module "code_interpreter" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/code-interpreter"
  
  network_mode       = "SANDBOX"
  execution_role_arn = aws_iam_role.code_interpreter.arn
  
  # No VPC configuration needed
}
```

**Workflow**:
```python
# AgentCore Runtime passes data to Code Interpreter
data = {
    "shares_before": 15.7,
    "split_ratio": 0.1,
    "current_price": 100.0
}

# Code Interpreter performs calculation (no network access needed)
code = f"""
shares_after = {data['shares_before']} * {data['split_ratio']}
whole_shares = int(shares_after)
fractional_shares = shares_after - whole_shares
cash_in_lieu = fractional_shares * {data['current_price']}
print(f"Cash in lieu: ${cash_in_lieu:.2f}")
"""

# Result returned to AgentCore Runtime
```

---

### VPC Mode (Recommended for Corporate Actions)
**Description**: Runs inside your VPC with access to private resources

**Capabilities**:
- ✅ Access VPC resources (RDS, DynamoDB via VPC endpoints)
- ✅ Access private databases and services
- ✅ VPC-level security controls
- ❌ No internet access (unless NAT Gateway configured)
- ❌ Cannot download packages (unless NAT Gateway configured)

**Security**: Medium-High - VPC isolation with controlled access

**Use Cases**:
- Query databases for calculations
- Access private APIs within VPC
- Corporate actions processing (query positions, validate data)
- Any scenario requiring private resource access

**Example**:
```hcl
module "code_interpreter" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/code-interpreter"
  
  network_mode       = "VPC"
  execution_role_arn = aws_iam_role.code_interpreter.arn
  
  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [aws_security_group.code_interpreter.id]
  }
}
```

**Workflow**:
```python
# Code Interpreter can query RDS directly
code = """
import psycopg2

conn = psycopg2.connect(
    host=os.environ['RDS_ENDPOINT'],
    database='corporate_actions',
    user='code_interpreter'
)

cursor = conn.cursor()
cursor.execute(
    "SELECT SUM(shares) FROM positions WHERE security_id = %s",
    ('SHOP',)
)
total_shares = cursor.fetchone()[0]
print(f"Total shares: {total_shares}")
"""
```

---

## Network Mode Comparison

| Feature | PUBLIC | SANDBOX | VPC |
|---------|--------|---------|-----|
| Internet Access | ✅ Yes | ❌ No | ❌ No* |
| VPC Resources | ❌ No | ❌ No | ✅ Yes |
| Download Packages | ✅ Yes | ❌ No | ❌ No* |
| Security Level | Low | High | Medium-High |
| Use Case | Dev/Testing | Pure Calculations | Private Resources |
| Cost | Low | Low | Medium** |

\* Unless NAT Gateway configured  
\*\* VPC endpoints and ENI costs apply

---

## Choosing the Right Mode

### Use PUBLIC if:
- Development/testing environment
- Need to call external APIs
- Need to download Python packages dynamically
- Security is not a primary concern

### Use SANDBOX if:
- Production environment with strict security requirements
- Only need to perform calculations on data passed from AgentCore Runtime
- Don't need network access
- Want maximum isolation

### Use VPC if:
- Need to access private databases (RDS, Aurora)
- Need to access DynamoDB via VPC endpoints
- Need to call private APIs within your VPC
- Want VPC-level security controls

---

## Corporate Actions Use Case

For the Corporate Actions Orchestrator, **VPC mode is recommended** because:

1. **Database Access**: Code Interpreter may need to query RDS for position data
2. **DynamoDB Access**: May need to read/write events via VPC endpoints
3. **Security**: VPC isolation provides security while allowing necessary access
4. **Consistency**: Same VPC as AgentCore Runtime for simplified networking

**Architecture**:
```
AgentCore Runtime (VPC)
    ↓
Code Interpreter (VPC)
    ↓
┌───────────────┴───────────────┐
↓                               ↓
RDS (Private Subnet)    DynamoDB (VPC Endpoint)
```

**Alternative (SANDBOX mode)**:
If Code Interpreter only performs calculations on data passed from AgentCore Runtime (no direct database access), SANDBOX mode provides maximum security:

```
AgentCore Runtime (VPC)
    ↓ (queries RDS, passes data)
Code Interpreter (SANDBOX)
    ↓ (performs calculation, returns result)
AgentCore Runtime (VPC)
    ↓ (writes result to DynamoDB)
```

## IAM Role Requirements

The execution role must have permissions for:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/bedrock/code-interpreter/*"
    }
  ]
}
```

For VPC mode, add:
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

## Integration with AgentCore Runtime

Pass the Code Interpreter ID to your AgentCore Runtime:

```hcl
module "agentcore_runtime" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/code-interpreter"

  # ... other configuration ...

  environment_variables = {
    CODE_INTERPRETER_ID  = module.code_interpreter.code_interpreter_id
    CODE_INTERPRETER_ARN = module.code_interpreter.code_interpreter_arn
  }
}
```

In your Python code:
```python
import boto3

bedrock = boto3.client('bedrock-agent-runtime')

# Use Code Interpreter for dynamic calculations
response = bedrock.invoke_code_interpreter(
    codeInterpreterArn=os.environ['CODE_INTERPRETER_ARN'],
    code="# Python code to execute\nresult = 100 * 10\nprint(result)",
    sessionId="session-123"
)
```

## Architecture Simplification

Code Interpreter eliminates the need for:
- Separate Lambda functions for calculations
- Complex error handling for edge cases
- Hardcoded business logic for every scenario

Instead, the AI agent dynamically generates Python code to handle unprecedented events.

## Cost Optimization

- Pay only for actual code execution time
- No idle compute costs (unlike Lambda reserved concurrency)
- SANDBOX mode has no data transfer costs

<!-- BEGIN_TF_DOCS -->

## Usage

```hcl
# Basic Code Interpreter Example

module "code_interpreter" {
  source = "github.com/islamelkadi/terraform-aws-bedrock//modules/code-interpreter"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description        = var.description
  network_mode       = var.network_mode
  execution_role_arn = var.execution_role_arn

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
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagentcore_code_interpreter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_code_interpreter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Code Interpreter | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ARN of the IAM role that the Code Interpreter assumes. Required for SANDBOX mode | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Code Interpreter | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Network mode for the Code Interpreter. Valid values: PUBLIC, SANDBOX, VPC | `string` | `"SANDBOX"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls with documented justification | <pre>object({<br/>    disable_sandbox_requirement = optional(bool, false)<br/>    justification               = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_sandbox_requirement": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>    data_protection = object({<br/>      require_versioning  = bool<br/>      require_mfa_delete  = bool<br/>      require_backup      = bool<br/>      require_lifecycle   = bool<br/>      block_public_access = bool<br/>      require_replication = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration for the Code Interpreter. Required when network\_mode is VPC | <pre>object({<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_code_interpreter_arn"></a> [code\_interpreter\_arn](#output\_code\_interpreter\_arn) | ARN of the Code Interpreter |
| <a name="output_code_interpreter_id"></a> [code\_interpreter\_id](#output\_code\_interpreter\_id) | Unique identifier of the Code Interpreter |
| <a name="output_code_interpreter_name"></a> [code\_interpreter\_name](#output\_code\_interpreter\_name) | Name of the Code Interpreter |
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | ARN of the Code Interpreter execution role |
| <a name="output_network_mode"></a> [network\_mode](#output\_network\_mode) | Network mode of the Code Interpreter |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the Code Interpreter |

## Example

See [example/](example/) for a complete working example with all features.

