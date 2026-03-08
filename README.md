# Terraform AWS Bedrock Module

Reusable Terraform module for AWS Bedrock AI services including agents, runtimes, and code interpreters.

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.

## Security

### Security Controls

Implements controls for FSBP, CIS, NIST 800-53/171, and PCI DSS v4.0:

- IAM least privilege for agent roles
- KMS encryption at rest and in transit
- CloudWatch Logs for agent invocation audit trail
- Content filtering guardrails support
- Security control overrides with audit justification

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| KMS encryption | Optional | Required | Required |
| IAM least privilege | Enforced | Enforced | Enforced |
| CloudWatch Logs | Optional | Required | Required |
| Content filtering guardrails | Optional | Recommended | Required |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.

### Security Scan Suppressions

This module suppresses certain Checkov security checks that are either not applicable to example/demo code or represent optional features. The following checks are suppressed in `.checkov.yaml`:

**Module Source Versioning (CKV_TF_1, CKV_TF_2)**
- Suppressed because we use semantic version tags (`?ref=v1.0.0`) instead of commit hashes for better maintainability and readability
- Semantic versioning is a valid and widely-accepted versioning strategy for stable releases

**KMS IAM Policies (CKV_AWS_111, CKV_AWS_356, CKV_AWS_109)**
- Suppressed in example code where KMS modules use flexible IAM policies for demonstration purposes
- Production deployments should customize KMS policies based on specific security requirements and apply least privilege principles

**Bedrock and VPC Optional Features**
- **VPC Public Subnets (CKV_AWS_130)**: Public subnets are designed to auto-assign public IPs for resources that need internet access; this is intentional
- **Bedrock Agent Guardrails (CKV_AWS_383)**: Optional feature that adds complexity; enable based on content filtering requirements
- **Security Group Attachment (CKV2_AWS_5)**: Security groups in example code may not be immediately attached; users will attach them to their resources
- **Default Security Group (CKV2_AWS_12)**: Default security group restrictions should be managed at the VPC module level, not in consuming modules

## Submodules

| Submodule | Description |
|-----------|-------------|
| [agentcore](modules/agentcore/) | Bedrock Agents with knowledge bases, action groups, and aliases |
| [agentcore-runtime](modules/agentcore-runtime/) | AgentCore Runtime with S3-based code deployment |
| [code-interpreter](modules/code-interpreter/) | Bedrock Code Interpreter in SANDBOX or VPC mode |

## Module Structure

```
terraform-aws-bedrock/
├── modules/
│   ├── agentcore/
│   │   ├── example/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── params/input.tfvars
│   │   └── ...
│   ├── agentcore-runtime/
│   │   ├── example/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── params/input.tfvars
│   │   └── ...
│   └── code-interpreter/
│       ├── example/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   └── params/input.tfvars
│       └── ...
└── README.md
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.3 |
| aws | >= 6.34 |

## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->


## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
