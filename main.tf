# -----------------------------------------------------
# Atom: IAM Policy
# Creates a standalone IAM managed policy document.
# -----------------------------------------------------
resource "aws_iam_policy" "this" {
  count = module.this.enabled ? 1 : 0

  name        = module.this.id
  description = coalesce(var.description, "Managed policy: ${module.this.id}")
  path        = var.path
  policy      = var.policy

  tags = local.tags
}
