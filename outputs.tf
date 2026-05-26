output "enabled" {
  description = "Whether the module is enabled"
  value       = local.enabled
}

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = try(aws_iam_policy.this[0].arn, null)
}

output "policy_id" {
  description = "ID of the IAM policy"
  value       = try(aws_iam_policy.this[0].policy_id, null)
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = try(aws_iam_policy.this[0].name, null)
}
