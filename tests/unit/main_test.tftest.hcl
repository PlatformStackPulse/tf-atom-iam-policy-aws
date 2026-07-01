# -----------------------------------------------------------------------------
# Unit tests — tf-atom-iam-policy-aws
#
# Mock provider: no real AWS calls. Assertions are restricted to values that are
# KNOWN at plan time (the tf-label id string, input pass-throughs, resource
# count). Computed attributes like .arn / .policy_id are unknown under a mock
# provider, so they are NOT asserted here.
# -----------------------------------------------------------------------------

mock_provider "aws" {}

variables {
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = ["arn:aws:s3:::example-bucket", "arn:aws:s3:::example-bucket/*"]
    }]
  })
}

# The module creates exactly one policy when enabled, the tf-label id drives the
# policy name, and the enabled output reflects the input.
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = output.enabled == true
    error_message = "Module should be enabled by default"
  }

  assert {
    condition     = length(aws_iam_policy.this) == 1
    error_message = "Exactly one aws_iam_policy should be planned when enabled"
  }

  assert {
    condition     = output.policy_name == "eg-test-thing"
    error_message = "policy_name should equal the tf-label id 'eg-test-thing'"
  }
}

# When disabled, the module creates no resources and arn/name outputs are null.
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = output.enabled == false
    error_message = "Module should be disabled"
  }

  assert {
    condition     = length(aws_iam_policy.this) == 0
    error_message = "No aws_iam_policy should be planned when disabled"
  }

  assert {
    condition     = output.policy_arn == null
    error_message = "policy_arn should be null when disabled"
  }
}
