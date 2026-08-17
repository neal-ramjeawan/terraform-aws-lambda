# terraform-aws-lambda

A generic Lambda function primitive: execution role, CloudWatch log group
with bounded retention, and an `allowed_triggers` input that generates
invoke permissions for whatever needs to call it. Built to be composed by
other modules (see `secrets-manager`, which uses this internally for its
optional rotation function) as much as used directly.

## Usage

```hcl
module "notifier" {
  source = "git::https://github.com/neal-ramjeawan/terraform-aws-lambda.git?ref=v0.1.2"

  function_name    = "myapp-notifier"
  filename         = "notifier.zip"
  source_code_hash = filebase64sha256("notifier.zip")
  handler          = "index.handler"

  environment_variables = {
    SLACK_WEBHOOK_URL = "..."
  }

  allowed_triggers = {
    eventbridge = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.this.arn
    }
  }

  tags = {
    Environment = "prod"
  }
}
```

## Reference

Auto-generated from `variables.tf`/`outputs.tf` on every PR — see `.github/workflows/docs.yml`. Don't hand-edit between the markers, it'll just get overwritten.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.triggers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_inline_policy_json"></a> [additional\_inline\_policy\_json](#input\_additional\_inline\_policy\_json) | Optional inline policy document (JSON string) to attach directly to the execution role — the hook other modules use to grant scoped permissions (e.g. access to one specific secret). | `string` | `null` | no |
| <a name="input_additional_policy_arns"></a> [additional\_policy\_arns](#input\_additional\_policy\_arns) | Extra managed policy ARNs to attach to the execution role, beyond the basic CloudWatch Logs policy every function gets. | `list(string)` | `[]` | no |
| <a name="input_allowed_triggers"></a> [allowed\_triggers](#input\_allowed\_triggers) | Map of principals allowed to invoke this function. Each entry creates one aws\_lambda\_permission. Example: { secretsmanager = { principal = "secretsmanager.amazonaws.com", source\_arn = aws\_secretsmanager\_secret.this.arn } } | <pre>map(object({<br/>    principal  = string<br/>    source_arn = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_attach_additional_inline_policy"></a> [attach\_additional\_inline\_policy](#input\_attach\_additional\_inline\_policy) | Whether to attach additional\_inline\_policy\_json. Leave null (the default) to infer it from whether additional\_inline\_policy\_json is set — fine for direct use. Set this explicitly instead when calling this module from another module and the JSON's presence isn't statically known at plan time (e.g. it comes from a conditionally-created data source) — a count can never depend on an unknown value, so inference breaks in that case and this is the escape hatch. | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the function. | `string` | `""` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables passed to the function. | `map(string)` | `{}` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | Path to the deployment package (.zip) to deploy. | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function. | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint, e.g. 'index.handler'. | `string` | `"index.handler"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log group retention, in days. | `number` | `14` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Memory allocated to the function, in MB. | `number` | `128` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Lambda runtime identifier. | `string` | `"python3.12"` | no |
| <a name="input_source_code_hash"></a> [source\_code\_hash](#input\_source\_code\_hash) | Base64-encoded SHA256 of the deployment package, used to detect code changes. Pass filebase64sha256(var.filename) or an archive\_file data source's output\_base64sha256. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Function timeout, in seconds. | `number` | `10` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Security group IDs for the function's VPC network interfaces. Required if vpc\_subnet\_ids is set. | `list(string)` | `null` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | Subnet IDs to run the function in, if it needs to reach something in a VPC (e.g. an RDS instance for database credential rotation). Leave null to run outside a VPC. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function. |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | Invoke ARN, needed by some trigger types (e.g. API Gateway integrations). |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch log group. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the execution role. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the execution role. |
<!-- END_TF_DOCS -->

## Composing this module from another module

This is the pattern
[`terraform-aws-secrets-manager`](https://github.com/neal-ramjeawan/terraform-aws-secrets-manager)
uses — a parent module builds its own deployment package and permissions,
then delegates the actual function to this one via a pinned tag:

```hcl
module "rotation_lambda" {
  source = "git::https://github.com/neal-ramjeawan/terraform-aws-lambda.git?ref=v0.1.2"

  function_name                   = "${var.secret_name}-rotation"
  filename                        = data.archive_file.rotation_lambda.output_path
  source_code_hash                = data.archive_file.rotation_lambda.output_base64sha256
  additional_inline_policy_json   = data.aws_iam_policy_document.rotation_permissions.json
  attach_additional_inline_policy = true # known statically — don't let Terraform infer it from the data source above, which isn't known until apply

  allowed_triggers = {
    secretsmanager = {
      principal  = "secretsmanager.amazonaws.com"
      source_arn = aws_secretsmanager_secret.this.arn
    }
  }
}
```

## Notes

- `filename` has no default on purpose — this module doesn't build a
  package for you, it deploys one you (or a parent module) already built.
- `additional_inline_policy_json` is the hook for scoped, resource-specific
  permissions (e.g. "read this one secret") that don't belong as a shared
  managed policy.
- `vpc_subnet_ids`/`vpc_security_group_ids` are there for the case a
  function needs to reach something private (an RDS instance for database
  credential rotation, for example) — leave both null to run outside a VPC,
  which is simpler and what most functions here need.

## Testing

```bash
terraform test
```

Runs `tests/lambda-function.tftest.hcl` against a mocked AWS provider — no
credentials, no real resources, no cost. Requires Terraform 1.7.0+.