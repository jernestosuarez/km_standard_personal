---
type: architecture-decision
title: AD-001 — self-hosted production execution
description: Selects the Glassity worker execution boundary for production tenant workloads and synthetic development.
tags: [glassity, security, architecture, worker, ad-001]
resource: glassity/decisions/
timestamp: 2026-08-27
lifecycle: active
---

# AD-001 — self-hosted production execution

## Status

**Approved by the accountable owner on 2026-08-27.** This resolves AD-001 at the security-design layer only. It does not approve a worker implementation, production release, or residual risk.

## Decision

Production tenant workloads use **self-hosted sandboxes in Glassity-controlled infrastructure**. Each worker run receives one isolated tenant context. Raw customer files, the worker filesystem, tool processes, network egress, and runtime credentials remain inside that boundary.

Anthropic continues to provide the Managed Agents control plane and model inference. Self-hosting therefore does **not** mean that nothing leaves Glassity: authorized model inputs and tool results still pass through Anthropic's control plane. SEC-015 remains binding and requires re-authorization at use time and transmission of only the minimal authorized content.

Anthropic-managed cloud sandboxes may be used for development, CI, or evaluation only when every input is **strictly synthetic**. For this decision, synthetic means generated specifically for testing and never derived from tenant or prospect data. It excludes real customer content and also excludes anonymized, pseudonymized, redacted, sampled, or paraphrased excerpts; production identifiers, pointers, metadata, credentials, and secrets are prohibited.

## Responsibility split

| Boundary | Glassity responsibility | Anthropic responsibility |
|---|---|---|
| Sandbox | Select, build, pin, harden, patch, and attest the image; run non-root with least privilege and isolated tenant filesystems. | No inspection or verification of the self-hosted image. |
| Network | Deny egress by default and allow only contractually named endpoints. | Secure the Managed Agents control plane; model and permitted platform services remain provider paths. |
| Credentials | Issue, scope, inject, rotate, revoke, and prevent logging of environment and per-session credentials. | Validate provider credentials and control-plane authorization according to the contracted service. |
| Tools and skills | Enforce the external tool allowlist, constrain arguments and filesystem access, and verify the approved skill set and repository revision before execution. | Run the configured agent/control-plane behavior; configured tools and skills do not transfer their trust decision to Anthropic. |
| Tenant data | Authorize every pointer dereference, minimize model inputs and tool results, attribute activity, and prevent cross-tenant access. | Process data that Glassity deliberately sends through the control plane under the applicable contract and provider lifecycle. |
| Cleanup and evidence | Remove per-run files and credentials, detect failed teardown, retain minimized audit evidence, and prove VER-015 before release. | Provide available platform evidence for the control-plane portion of VER-015. |

## Consequences

- The worker contract must specify a self-hosted production environment and prove one isolated sandbox per tenant run.
- Sandbox image hardening, egress control, secret handling, tool blast radius, cleanup after normal and abnormal termination, and incident response are first-version engineering scope owned by Glassity.
- Ernesto must be shown this operational cost when the first-version scope is reviewed; it is not deferred infrastructure.
- Managed development must fail closed if test-data provenance cannot prove that the inputs are strictly synthetic.
- AD-002 through AD-005 remain unresolved and blocking. AD-004 still prevents a worker/Git credential contract, and VER-015 still prevents release.
- No residual risk from TM-016 or any other Phase S0 threat is accepted by this decision.

## Rationale

Glassity processes customer vaults containing other organizations' internal files. Keeping file and tool execution in Glassity-controlled infrastructure better matches the product's governance promise and reduces the provider-side raw-file footprint. The added operational burden is accepted as an explicit production design cost, not hidden as later hardening.

## Rejected alternatives

### Anthropic-managed production sandboxes

Rejected for production because raw customer files and tool execution would occur in Anthropic-managed infrastructure and Managed Agents sessions are stateful. The lower operational burden does not outweigh the customer-governance boundary for the first production release.

### Dual production modes in v1

Rejected because two production execution paths would double security boundaries, conformance evidence, incident procedures, and drift risk before either path is proven.

## Required follow-on evidence

- SEC-008, SEC-015, SEC-017, and SEC-018 must be encoded in the future worker contract.
- VER-006, VER-012, VER-014, and VER-015 must pass before release.
- AD-004 must define environment and per-session secret issuance, rotation, revocation, and Git credential scope before worker contract work.
- AD-005 must define deletion and provider-lifecycle obligations for transcripts, tool results, audit data, and self-hosted per-run artifacts.

## References

Accessed 2026-08-27:

- [Anthropic self-hosted sandboxes](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes)
- [Anthropic self-hosted sandbox security model](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security)
- [Anthropic API and data retention](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention)
