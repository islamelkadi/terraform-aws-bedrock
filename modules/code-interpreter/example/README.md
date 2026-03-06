# Basic Code Interpreter Example

This example creates a Bedrock Code Interpreter in SANDBOX mode using a fictitious IAM role ARN.

## Usage

```bash
terraform init
terraform plan -var-file=params/input.tfvars
terraform apply -var-file=params/input.tfvars
```

## What This Example Creates

- Code Interpreter in SANDBOX mode with isolated execution environment

## Clean Up

```bash
terraform destroy -var-file=params/input.tfvars
```
