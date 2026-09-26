resource "aws_db_subnet_group" "app" {
  name        = "aws-secure-portal-db-subnet-group"
  description = "Private database subnets for AWS Secure Portal"

  subnet_ids = [
    aws_subnet.this["db-private-a"].id,
    aws_subnet.this["db-private-b"].id
  ]

  tags = {
    Name        = "aws-secure-portal-db-subnet-group"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_instance" "app" {
  identifier = "aws-secure-portal-db"

  engine         = "postgres"
  engine_version = "18.3"
  instance_class = "db.t4g.micro"

  db_name  = "portaldb"
  username = "portaladmin"
  port     = 5432

  allocated_storage  = 20
  storage_type       = "gp3"
  iops               = 3000
  storage_throughput = 125
  storage_encrypted  = true

  multi_az            = false
  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.app.name

  vpc_security_group_ids = [
    aws_security_group.db.id
  ]

  backup_retention_period = 1
  copy_tags_to_snapshot   = true

  auto_minor_version_upgrade = true
  monitoring_interval        = 0

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name        = "aws-secure-portal-db"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}
