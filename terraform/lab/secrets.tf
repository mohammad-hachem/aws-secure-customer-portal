resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "aws-secure-portal/db-credentials"
  description = "RDS PostgreSQL credentials for AWS Secure Portal"

  recovery_window_in_days = 0

  tags = {
    Name        = "aws-secure-portal-db-credentials"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}
