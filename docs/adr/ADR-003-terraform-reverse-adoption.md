# ADR-003: Reverse-adopt the validated environment into Terraform

## Status

Accepted

## Context

The goal of the project was to learn and validate AWS service behavior, not only to produce HCL. Building everything from Terraform first would make it easier to miss how the services behave and fail operationally.

## Decision

Build and test the environment manually first, then define the equivalent Terraform resources and import existing infrastructure where supported.

The workflow was:

```text
Manual deployment
→ functional validation
→ failure diagnosis
→ Terraform configuration
→ import/adoption
→ plan review
→ apply intended changes
→ final no-drift plan
```

## Rationale

This preserved the operational learning from manual deployment while ending with declarative, reviewable Infrastructure as Code.

It also exposed several adoption-specific issues, including resources that could be imported directly, security-group rules that needed individual adoption, and GuardDuty detector features that the provider did not support importing.

## Consequences

- Adoption required careful comparison of live AWS state and HCL.
- Every Terraform plan had to be reviewed for destructive or unintended changes.
- The final `No changes` plan became a useful proof that the live environment and Terraform configuration were synchronized.
