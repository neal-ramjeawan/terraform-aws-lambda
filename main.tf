data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

# Every function gets CloudWatch Logs write access — there's no real reason
# not to, and debugging a function with no logs is miserable.
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

locals {
  # Whether to attach the inline policy is normally inferred from whether
  # additional_inline_policy_json is set. That inference breaks when this
  # module is composed by another module and the value comes from a
  # conditionally-created data source — under full provider mocking (and
  # in some real cross-resource cases too), that value's presence isn't
  # knowable until apply, and a count can never depend on an unknown
  # value. attach_additional_inline_policy lets a caller state the answer
  # directly instead of making Terraform infer it.
  attach_inline_policy = (
    var.attach_additional_inline_policy != null
    ? var.attach_additional_inline_policy
    : var.additional_inline_policy_json != null
  )
}

resource "aws_iam_role_policy" "inline" {
  count = local.attach_inline_policy ? 1 : 0

  name   = "${var.function_name}-inline"
  role   = aws_iam_role.this.id
  policy = var.additional_inline_policy_json
}

# Created explicitly (rather than letting Lambda auto-create it on first
# invoke) so retention is actually bounded — the default is "never expire",
# which quietly racks up storage cost forever.
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  description      = var.description
  role             = aws_iam_role.this.arn
  runtime          = var.runtime
  handler          = var.handler
  filename         = var.filename
  source_code_hash = var.source_code_hash
  memory_size      = var.memory_size
  timeout          = var.timeout

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  tags = var.tags

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_lambda_permission" "triggers" {
  for_each = var.allowed_triggers

  statement_id  = "Allow${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = each.value.principal
  source_arn    = try(each.value.source_arn, null)
}
