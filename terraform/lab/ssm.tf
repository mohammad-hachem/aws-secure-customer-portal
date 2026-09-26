resource "aws_iam_role_policy_attachment" "app_ssm_core" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "ssm_vpce" {
  name        = "aws-secure-portal-ssm-vpce-sg"
  description = "aws-secure-portal-ssm-vpce-sg"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "aws-secure-portal-ssm-vpce-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssm_vpce_from_app" {
  security_group_id            = aws_security_group.ssm_vpce.id
  referenced_security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "HTTPS from application instances"
}

resource "aws_vpc_security_group_egress_rule" "app_to_ssm_vpce" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.ssm_vpce.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "HTTPS to Systems Manager VPC endpoints"
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-central-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.this["app-private-a"].id
  ]

  security_group_ids = [
    aws_security_group.ssm_vpce.id
  ]

  tags = {
    Name = "vpce-ssm"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-central-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.this["app-private-a"].id
  ]

  security_group_ids = [
    aws_security_group.ssm_vpce.id
  ]

  tags = {
    Name = "vpce-ssmmessages"
  }
}
