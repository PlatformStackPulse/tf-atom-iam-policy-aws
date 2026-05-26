provider "aws" {
  region = "eu-west-1"
}

module "iam_policy" {
  source = "../../"

  namespace   = "acme"
  environment = "prod"
  name        = "lambda-s3-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AllowS3Read"
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = ["arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"]
    }]
  })
}
