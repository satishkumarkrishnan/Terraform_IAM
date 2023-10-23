terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}
# To create IAM role using TF
resource "aws_iam_role" "tokyo_IAM_role" {
  name = "tokyo_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "Tokyo_User"
  }
}

# To create IAM role policy using TF
resource "aws_iam_role_policy" "tokyo_IAM_policy" {
  name = "tokyo_policy"
  role = aws_iam_role.tokyo_IAM_role.id
  depends_on = [aws_iam_role.tokyo_IAM_role]

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "tokyo_policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.tokyo_IAM_role.id
  policy_arn = aws_iam_policy.tokyo_policy.arn  
  depends_on = [aws_iam_role.tokyo_IAM_role, aws_iam_role_policy.tokyo_policy]
}