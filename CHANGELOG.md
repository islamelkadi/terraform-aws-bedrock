## [1.1.0](https://github.com/islamelkadi/terraform-aws-bedrock/compare/v1.0.2...v1.1.0) (2026-03-15)


### Features

* add manual triggering to release workflow ([9cd662d](https://github.com/islamelkadi/terraform-aws-bedrock/commit/9cd662df92e17f30b8cf528e182cdc9f0f1181ea))


### Documentation

* add GitHub Actions workflow status badges ([fa17e54](https://github.com/islamelkadi/terraform-aws-bedrock/commit/fa17e54ff46fa1da9e073bee19e356635be0bb73))
* add security scan suppressions section to README ([9ce9fbd](https://github.com/islamelkadi/terraform-aws-bedrock/commit/9ce9fbd4bf36bf120861263c1c446845a0177881))

## [1.0.2](https://github.com/islamelkadi/terraform-aws-bedrock/compare/v1.0.1...v1.0.2) (2026-03-08)


### Bug Fixes

* add CKV_TF_1 suppression for external module metadata ([da43911](https://github.com/islamelkadi/terraform-aws-bedrock/commit/da43911cc4c02b10647c8577bda4159b1fdce314))
* add skip-path for .external_modules in Checkov config ([d4bbffd](https://github.com/islamelkadi/terraform-aws-bedrock/commit/d4bbffde63299608f15fbb8c640f7e68458c4115))
* address Checkov security findings ([e07e039](https://github.com/islamelkadi/terraform-aws-bedrock/commit/e07e0397b7e4eddfb9dd99fb130c4ea90962152c))
* correct .checkov.yaml format to use simple list instead of id/comment dict ([3090c33](https://github.com/islamelkadi/terraform-aws-bedrock/commit/3090c33b46dfcbf448be4f122ce102118c1ddfef))
* remove skip-path from .checkov.yaml, rely on workflow-level skip_path ([1928502](https://github.com/islamelkadi/terraform-aws-bedrock/commit/19285028497603167ffe20d7d7a3daf8365803ee))
* update workflow path reference to terraform-security.yaml ([35098e6](https://github.com/islamelkadi/terraform-aws-bedrock/commit/35098e67e94df212f80b905807db90fb122bd78c))

## [1.0.1](https://github.com/islamelkadi/terraform-aws-bedrock/compare/v1.0.0...v1.0.1) (2026-03-08)


### Code Refactoring

* enhance examples with real infrastructure and improve code quality ([a6f722b](https://github.com/islamelkadi/terraform-aws-bedrock/commit/a6f722b4e858b82be4048a68cecf8541720d2ff4))

## 1.0.0 (2026-03-07)


### ⚠ BREAKING CHANGES

* First publish - Bedrock Terraform module

### Features

* First publish - Bedrock Terraform module ([b556018](https://github.com/islamelkadi/terraform-aws-bedrock/commit/b5560188b7ace56e9c807f1f072a5262506c0dd4))
