# Local values for naming and tagging

locals {
  # Construct agent name from components
  name_parts = compact(concat(
    [var.namespace],
    [var.environment],
    [var.name],
    var.attributes
  ))

  agent_name = join(var.delimiter, local.name_parts)

  # Merge tags with defaults
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Name   = local.agent_name
      Module = "terraform-aws-bedrock-agent"
    }
  )

  # Combine inline policies for role module
  inline_policies = var.create_role ? merge(
    { "bedrock-invoke" = data.aws_iam_policy_document.bedrock_invoke[0].json },
    var.knowledge_base_id != null ? { "knowledge-base" = data.aws_iam_policy_document.knowledge_base[0].json } : {},
    var.inline_policies
  ) : {}
}
