data "aws_iam_policy_document" "app_ec2_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "app_read_db_secret" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.db_credentials.arn
    ]
  }
}

resource "aws_iam_role" "app" {
  name        = "aws-secure-portal-app-role"
  description = "IAM role for AWS Secure Portal application EC2 instances"

  assume_role_policy = data.aws_iam_policy_document.app_ec2_assume_role.json

  tags = {
    Name        = "aws-secure-portal-app-role"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "app_read_db_secret" {
  name = "aws-secure-portal-read-db-secret"
  role = aws_iam_role.app.name

  policy = data.aws_iam_policy_document.app_read_db_secret.json
}

resource "aws_iam_instance_profile" "app" {
  name = "aws-secure-portal-app-role"
  role = aws_iam_role.app.name

  tags = {
    Name        = "aws-secure-portal-app-role"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}
