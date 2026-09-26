resource "aws_security_group" "eice" {
  name        = "aws-secure-portal-eice-sg"
  description = "EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "aws-secure-portal-eice-sg"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_egress_rule" "eice_to_app" {
  security_group_id = aws_security_group.eice.id

  description                  = "SSH to private application instances"
  referenced_security_group_id = aws_security_group.app.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_from_eice" {
  security_group_id = aws_security_group.app.id

  description                  = "SSH from EC2 Instance Connect Endpoint"
  referenced_security_group_id = aws_security_group.eice.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id = aws_subnet.this["app-private-a"].id

  security_group_ids = [
    aws_security_group.eice.id
  ]

  preserve_client_ip = false

  tags = {
    Name        = "aws-secure-portal-eice"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}
