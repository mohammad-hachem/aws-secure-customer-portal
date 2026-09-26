# Terraform Adoption and Validation

## Approach

The infrastructure was not created from Terraform on day one.

The workflow was intentionally:

```text
Manual deployment
→ functional validation
→ troubleshooting
→ Terraform configuration
→ import existing resources
→ review plan
→ apply only intended changes
→ final no-drift plan
```

This made the exercise useful both for AWS operations and for Infrastructure-as-Code adoption.

## Examples of Imported Resources

### Auto Scaling Policy

```powershell
terraform import aws_autoscaling_policy.app_cpu_target `
  "aws-secure-portal-asg/aws-secure-portal-cpu-target"
```

### Systems Manager VPC Endpoints

```powershell
terraform import aws_vpc_endpoint.ssm `
  "vpce-xxxxxxxxxxxxxxxxx"

terraform import aws_vpc_endpoint.ssmmessages `
  "vpce-xxxxxxxxxxxxxxxxx"
```

### SSM IAM Policy Attachment

```powershell
terraform import aws_iam_role_policy_attachment.app_ssm_core `
  "aws-secure-portal-app-role/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
```

### Security Group Rules

Existing rules were imported by AWS security-group-rule ID:

```powershell
terraform import aws_vpc_security_group_ingress_rule.ssm_vpce_from_app `
  "sgr-xxxxxxxxxxxxxxxxx"

terraform import aws_vpc_security_group_egress_rule.app_to_ssm_vpce `
  "sgr-xxxxxxxxxxxxxxxxx"
```

### CloudTrail

```powershell
terraform import aws_cloudtrail.management `
  "arn:aws:cloudtrail:eu-central-1:<account-id>:trail/securanova-management-trail"
```

The CloudTrail S3 bucket, bucket policy, public-access block, and encryption configuration were also adopted into Terraform.

### GuardDuty

```powershell
terraform import aws_guardduty_detector.main `
  "<detector-id>"
```

The provider version used in the lab did not support import for `aws_guardduty_detector_feature`. Those feature resources were added to configuration and adopted through a reviewed apply against the existing detector.

## Auto Scaling Configuration

The target-tracking policy is equivalent to:

```hcl
resource "aws_autoscaling_policy" "app_cpu_target" {
  name                   = "aws-secure-portal-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = 60

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = 30
    disable_scale_in = false
  }
}
```

The target group was also updated in Terraform to use:

```hcl
health_check {
  path                = "/health"
  protocol            = "HTTP"
  port                = "traffic-port"
  healthy_threshold   = 2
  unhealthy_threshold = 2
  interval            = 30
  timeout             = 5
  matcher             = "200"
}
```

## SSM Endpoint Design

Both Systems Manager interface endpoints use a dedicated endpoint security group.

```hcl
resource "aws_vpc_security_group_ingress_rule" "ssm_vpce_from_app" {
  security_group_id            = aws_security_group.ssm_vpce.id
  referenced_security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "app_to_ssm_vpce" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.ssm_vpce.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}
```

This replaced an interim rule that pointed the SSM endpoint at the VPC default security group.

## GuardDuty Runtime Monitoring

Runtime monitoring remained disabled. Terraform was updated to reflect the disabled sub-configurations explicitly so the final plan would not attempt to alter them.

## Final Workflow

```powershell
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform plan
```

Final result:

```text
No changes. Your infrastructure matches the configuration.
```

That final plan confirmed that the deployed AWS environment and the Terraform configuration were synchronized.
