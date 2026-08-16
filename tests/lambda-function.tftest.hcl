# Fully mocks the AWS provider — no credentials, no real API calls, no cost.
# Run with: terraform test (from the repo root)
#
# Without the mock_data override below, aws_iam_policy_document's own
# computed `.json` output gets faked out too (mock_provider mocks the whole
# provider, not just resources that hit a real API) — and the fake string
# isn't valid JSON, which breaks anything downstream expecting a real
# policy document, like aws_iam_role.this.assume_role_policy.
mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect    = "Allow"
            Action    = "sts:AssumeRole"
            Principal = { Service = "lambda.amazonaws.com" }
          }
        ]
      })
    }
  }
}

variables {
  function_name = "test-function"
  filename      = "tests/fixtures/dummy.zip"
}

run "creates_function_with_defaults" {
  command = plan

  assert {
    condition     = aws_lambda_function.this.runtime == "python3.12"
    error_message = "Default runtime should be python3.12"
  }

  assert {
    condition     = length(aws_lambda_permission.triggers) == 0
    error_message = "No permissions should be created when allowed_triggers is empty"
  }

  assert {
    condition     = length(aws_iam_role_policy.inline) == 0
    error_message = "No inline policy should be created when additional_inline_policy_json is null"
  }
}

run "creates_one_permission_per_trigger" {
  command = plan

  variables {
    allowed_triggers = {
      secretsmanager = {
        principal  = "secretsmanager.amazonaws.com"
        source_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-abc123"
      }
    }
  }

  assert {
    condition     = length(aws_lambda_permission.triggers) == 1
    error_message = "Expected one lambda permission per allowed_triggers entry"
  }
}

run "attaches_additional_managed_policies" {
  command = plan

  variables {
    additional_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.additional) == 1
    error_message = "Expected one attachment per additional_policy_arns entry"
  }
}

run "log_group_retention_matches_variable" {
  command = plan

  variables {
    log_retention_days = 30
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.retention_in_days == 30
    error_message = "Log group retention should match log_retention_days"
  }
}
