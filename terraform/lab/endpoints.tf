resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.main.id

  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.app_a.id,
    aws_route_table.app_b.id
  ]

  tags = {
    Name        = "vpce-s3"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-central-1.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.this["app-private-a"].id,
    aws_subnet.this["app-private-b"].id
  ]

  security_group_ids = [
    aws_security_group.secrets_vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name        = "aws-secure-portal-secretsmanager-vpce"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}
