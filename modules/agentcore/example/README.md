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
