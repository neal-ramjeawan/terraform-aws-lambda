variable "function_name" {
  description = "Name of the Lambda function."
  type        = string
}

variable "description" {
  description = "Description of the function."
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Lambda runtime identifier."
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Function entrypoint, e.g. 'index.handler'."
  type        = string
  default     = "index.handler"
}

variable "filename" {
  description = "Path to the deployment package (.zip) to deploy."
  type        = string
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 of the deployment package, used to detect code changes. Pass filebase64sha256(var.filename) or an archive_file data source's output_base64sha256."
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Memory allocated to the function, in MB."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Function timeout, in seconds."
  type        = number
  default     = 10
}

variable "environment_variables" {
  description = "Environment variables passed to the function."
  type        = map(string)
  default     = {}
}

variable "additional_policy_arns" {
  description = "Extra managed policy ARNs to attach to the execution role, beyond the basic CloudWatch Logs policy every function gets."
  type        = list(string)
  default     = []
}

variable "additional_inline_policy_json" {
  description = "Optional inline policy document (JSON string) to attach directly to the execution role — the hook other modules use to grant scoped permissions (e.g. access to one specific secret)."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log group retention, in days."
  type        = number
  default     = 14
}

variable "allowed_triggers" {
  description = "Map of principals allowed to invoke this function. Each entry creates one aws_lambda_permission. Example: { secretsmanager = { principal = \"secretsmanager.amazonaws.com\", source_arn = aws_secretsmanager_secret.this.arn } }"
  type = map(object({
    principal  = string
    source_arn = optional(string)
  }))
  default = {}
}

variable "vpc_subnet_ids" {
  description = "Subnet IDs to run the function in, if it needs to reach something in a VPC (e.g. an RDS instance for database credential rotation). Leave null to run outside a VPC."
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "Security group IDs for the function's VPC network interfaces. Required if vpc_subnet_ids is set."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
