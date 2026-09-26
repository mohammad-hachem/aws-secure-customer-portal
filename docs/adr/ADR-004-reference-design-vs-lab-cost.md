# ADR-004: Separate the production reference design from the cost-optimized lab

## Status

Accepted

## Context

A resilient production design and a learning lab have different steady-state cost requirements.

## Decision

Document a production/reference architecture with:

- Multiple EC2 instances across two Availability Zones
- RDS Multi-AZ
- One NAT Gateway per Availability Zone
- VPC endpoints for selected AWS services

Run the hands-on lab with:

- ASG Min 1 / Desired 1 / Max 2
- Single-AZ RDS
- No NAT Gateway
- Only the VPC endpoints required for the tested paths

## Rationale

The lab still validates subnet placement, Auto Scaling, private service connectivity, security-group relationships, monitoring, and Terraform adoption without paying continuously for the full HA footprint.

## Consequences

- The lab should not be described as fully production-HA.
- The reference architecture shows the intended production posture.
- Cost optimization and availability trade-offs are explicit rather than hidden.
