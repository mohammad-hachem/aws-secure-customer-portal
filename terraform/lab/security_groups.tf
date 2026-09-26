resource "aws_security_group" "alb" {
  name        = "aws-secure-portal-alb-sg"
  description = "Public Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "aws-secure-portal-alb-sg"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "app" {
  name        = "aws-secure-portal-app-sg"
  description = "Private application servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "aws-secure-portal-app-sg"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Application traffic from ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.application_port
  to_port                      = var.application_port
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "db" {
  name        = "aws-secure-portal-db-sg"
  description = "RDS PostgreSQL database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "aws-secure-portal-db-sg"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from application servers"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Application traffic to private targets"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.application_port
  to_port                      = var.application_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  description                  = "PostgreSQL traffic to database"
  referenced_security_group_id = aws_security_group.db.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_to_s3" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS to Amazon S3"
  prefix_list_id    = aws_vpc_endpoint.s3.prefix_list_id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_security_group" "secrets_vpce" {
  name        = "aws-secure-portal-secrets-vpce-sg"
  description = "Allow private Secrets Manager access from portal application instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "aws-secure-portal-secrets-vpce-sg"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "secrets_vpce_from_app" {
  security_group_id            = aws_security_group.secrets_vpce.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "app_to_secrets_vpce" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.secrets_vpce.id
  description                  = "HTTPS to Secrets Manager VPC endpoint"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

data "aws_ec2_managed_prefix_list" "cloudfront_origin_facing" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_from_cloudfront" {
  security_group_id = aws_security_group.alb.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS from CloudFront origin-facing"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_cognito_https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS to Cognito authentication endpoints"
}
