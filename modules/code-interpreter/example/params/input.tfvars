namespace   = "example"
environment = "dev"
name        = "data-analysis"
region      = "us-east-1"

description        = "Code Interpreter for data analysis tasks"
network_mode       = "SANDBOX"
execution_role_arn = "arn:aws:iam::123456789012:role/code-interpreter-role"

tags = {
  Example = "CODE_INTERPRETER"
  Purpose = "DATA_ANALYSIS"
}
