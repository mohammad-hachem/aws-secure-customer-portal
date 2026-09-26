# Architecture Notes

## Request Path

```text
Users
  → Route 53
  → CloudFront
  → AWS WAF
  → Application Load Balancer
  → Cognito authentication
  → EC2 Auto Scaling Group
  → RDS PostgreSQL
```

## VPC Layout

The VPC spans two Availability Zones and uses six subnets:

```text
AZ-A
├─ Public subnet
├─ Private application subnet
└─ Private database subnet

AZ-B
├─ Public subnet
├─ Private application subnet
└─ Private database subnet
```

The ALB is deployed across the two public subnets.

The Auto Scaling Group uses both private application subnets.

RDS uses a DB subnet group containing both private database subnets. The lab database itself is Single-AZ to control cost, while the subnet group keeps the network design ready for Multi-AZ deployment.

## Private AWS Connectivity

No NAT Gateway is used.

```text
EC2 → S3 Gateway Endpoint → Amazon S3

EC2 → Secrets Manager Interface Endpoint → Secrets Manager

EC2 → SSM Interface Endpoint → Systems Manager API

EC2 → SSM Messages Interface Endpoint → Session / command messaging
```

## Security Group Relationships

```text
CloudFront managed prefix list
        ↓ HTTPS/443
      ALB SG
        ↓ TCP/3000
      App SG
        ↓ TCP/5432
       DB SG
```

Additional private-management paths:

```text
EICE SG → SSH/22 → App SG

App SG → HTTPS/443 → Secrets Manager Endpoint SG

App SG → HTTPS/443 → SSM Endpoint SG
```

## Event Path

```text
S3 object-created event
        ↓
       SQS
        ↓
      Lambda
        ↓
 processing / logging
```

Failed processing can move messages to the DLQ after the configured receive threshold.

## Security / Monitoring

```text
AWS API activity → CloudTrail → S3 audit bucket

AWS telemetry → GuardDuty → findings

CloudWatch metrics → Alarm → SNS → email
```

## Availability Notes

The application tier is multi-AZ because the ALB and ASG span two Availability Zones.

The RDS subnet group spans two AZs, but the lab database is intentionally Single-AZ for cost control. A production version could enable RDS Multi-AZ without redesigning the network layout.
