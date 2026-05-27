# Test 1: Module is enabled by default
run "enabled_by_default" {
  command = plan
  variables {
    namespace   = "test"
    environment = "dev"
    name        = "my-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::my-bucket/*"]
      }]
    })
  }
  assert {
    condition     = output.enabled == true
    error_message = "Module should be enabled by default"
  }
}

# Test 2: Module creates nothing when disabled
run "disabled_creates_nothing" {
  command = plan
  variables {
    enabled     = false
    namespace   = "test"
    environment = "dev"
    name        = "my-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["*"]
      }]
    })
  }
  assert {
    condition     = output.enabled == false
    error_message = "Module should be disabled"
  }
}

# Test 3: Policy ARN output is generated when enabled
run "policy_arn_output" {
  command = plan
  variables {
    namespace   = "test"
    environment = "dev"
    name        = "my-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup"]
        Resource = ["*"]
      }]
    })
  }
  assert {
    condition     = output.policy_name != null
    error_message = "Policy name should not be null when enabled"
  }
}
