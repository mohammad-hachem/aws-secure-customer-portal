# ADR-001: Keep application compute private

## Status

Accepted

## Context

The portal must be reachable from the Internet, but the EC2 application instances and database do not need direct public exposure.

## Decision

Run application instances only in private application subnets with no public IP addresses. Expose the application through CloudFront, AWS WAF, and an Application Load Balancer.

Use AWS Systems Manager for normal administration. Retain EC2 Instance Connect Endpoint as a separate private SSH path for cases where SSH is useful.

In the cost-optimized lab, omit NAT Gateways and use VPC endpoints for the AWS services the workload requires.

## Rationale

This reduces direct Internet exposure of the compute tier and keeps administrative access on controlled AWS paths. It also makes outbound dependencies explicit: either a private VPC endpoint is provided, or the production/reference design routes general Internet egress through a NAT Gateway.

## Consequences

- Application instances cannot be reached directly from the Internet.
- Systems Manager and endpoint security-group configuration become operational dependencies.
- A production workload that needs package repositories or third-party APIs requires NAT or another controlled egress design.
- The lab is cheaper, but deliberately less flexible for arbitrary outbound connectivity.
