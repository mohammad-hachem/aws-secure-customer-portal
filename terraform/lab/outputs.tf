output "vpc_id" {
  description = "Terraform-managed VPC ID."
  value       = aws_vpc.main.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID."
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."

  value = {
    public_a = aws_subnet.this["public-a"].id
    public_b = aws_subnet.this["public-b"].id
  }
}

output "application_subnet_ids" {
  description = "Private application subnet IDs."

  value = {
    app_a = aws_subnet.this["app-private-a"].id
    app_b = aws_subnet.this["app-private-b"].id
  }
}

output "database_subnet_ids" {
  description = "Private database subnet IDs."

  value = {
    db_a = aws_subnet.this["db-private-a"].id
    db_b = aws_subnet.this["db-private-b"].id
  }
}

output "security_group_ids" {
  description = "Application security group IDs."

  value = {
    alb = aws_security_group.alb.id
    app = aws_security_group.app.id
    db  = aws_security_group.db.id
  }
}

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway VPC Endpoint ID."
  value       = aws_vpc_endpoint.s3.id
}

output "eice_id" {
  description = "EC2 Instance Connect Endpoint ID."
  value       = aws_ec2_instance_connect_endpoint.main.id
}
