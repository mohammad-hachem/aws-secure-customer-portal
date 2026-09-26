# ADR-002: Restrict ALB ingress to CloudFront origin-facing addresses

## Status

Accepted

## Context

AWS WAF is attached at the CloudFront edge. If the Application Load Balancer can also be reached directly from arbitrary Internet addresses, a client could bypass the intended CloudFront/WAF path.

## Decision

Allow inbound HTTPS to the ALB security group only from the AWS-managed CloudFront origin-facing prefix list.

## Rationale

This constrains the network path to:

```text
Internet → CloudFront / WAF → ALB
```

and prevents ordinary direct-to-origin access at the network/transport layer.

## Consequences

- The ALB depends on the AWS-managed CloudFront origin-facing prefix list.
- CloudFront remains the intended public ingress path.
- Additional origin-hardening controls can be added in a production design if stronger distribution-specific restrictions are required.
