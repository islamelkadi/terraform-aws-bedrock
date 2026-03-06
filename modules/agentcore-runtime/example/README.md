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
