---
type: config
title: KM Deployment Binding
description: Records the canonical standard and optional enterprise organization profile that produced this hub.
tags: [config, deployment, provenance]
lifecycle: active
timestamp: {{INIT_DATE}}
canonical-standard-version: "{{KM_STANDARD_VERSION}}"
canonical-standard-revision: "{{KM_STANDARD_REVISION}}"
canonical-standard-source: "{{KM_STANDARD_SOURCE}}"
deployment-state: canonical
# The purpose interview (v1.25). The date the /km-init interview produced this hub's
# definition (below). An empty or absent value QUARANTINES the hub: hub-scan.sh reports it
# as an error, and an uninterviewed hub never scans green.
initiation-interview: "{{INIT_DATE}}"
# Routing keywords from the interview — harvested by the supervisor's hub registry and by
# the decision surface's per-hub attribution. Comma-separated, lowercase. Gated since v1.28:
# hub-scan.sh reports an empty or unsubstituted value as an error, because a surface that
# reads this field attributes nothing to a hub that left it blank.
routing-keywords: "{{ROUTING_KEYWORDS}}"
organization-profile-id: ""
organization-profile-revision: ""
enterprise-namespace: ""
enterprise-contract-revision: ""
# Hub species (Rule 6 — optional, added in v1.23). Two independent axes:
# station governs INTAKE (what may flow in); exposure governs OUTPUT (who may consume).
# Absent means station: domain, exposure: compartment. Build at the station, publish at
# the exposure.
# station: org-core | domain | engagement | publication
# exposure: never-public | compartment | counterparty | public
# Compartment declaration (optional, directional): who this hub is for, and who it must
# never reach. Free-form party names — hub-local content, never canonical. Cross-compartment
# flow is default-deny, Supervisor-mediated.
# compartment-audience: ""
# compartment-boundary: ""
---

# KM Deployment Binding

This hub was created from the canonical KM Standard revision recorded above.

`deployment-state: canonical` means no enterprise organization profile has been applied. Only an
authorized Supervisor may change the state to `organization-bound`, populate all four organization
and enterprise fields, and commit that customization separately.

The optional `station` and `exposure` fields declare the hub's species (STANDARD.md → Rule 6 →
"Station and exposure"): what may flow in, and who may consume out. Absent fields default to
`station: domain`, `exposure: compartment`; `hub-scan.sh` validates the values only when the
fields are present. The optional compartment fields declare audience and boundary for
Supervisor-mediated, default-deny cross-compartment flow.

## Hub definition (from the /km-init purpose interview, v1.25)

Recorded on {{INIT_DATE}}. This is the hub's manifest of intent — what it is for, for whom, and
where its boundaries sit. Changing it is a governed change like any other.

- **Purpose:** {{DESCRIPTION}}
- **Scope guard — in** (the admission rule: the condition under which a source is admitted here,
  not a topic label): {{SCOPE_IN}}
- **Scope guard — out:** {{SCOPE_OUT}}
- **Hard exclusions** (what this hub refuses *even when a routing keyword matches* — an exclusion
  never stated against a matching keyword never fires): {{HARD_EXCLUSIONS}}
- **Audiences and surfaces** (each audience named to the surface it gets — audience / owner /
  practitioner; STANDARD.md → "The decision surface: three surfaces"):
  {{AUDIENCE_SURFACES}}
- **Knowledge vs. records boundary** (what this hub curates as claims, and what stays in
  systems of record with pointers only — Rule 6): {{KNOWLEDGE_RECORDS_BOUNDARY}}
- **Evidence expectations** (what sources this hub will trust, and what always needs owner
  confirmation): {{EVIDENCE_EXPECTATIONS}}
- **Owner cadence** (how often the owner sits with the queue, and on which surface):
  {{OWNER_CADENCE}}
- **Sensitivity posture** (restricted classes expected here, and the outbound surfaces planned —
  elicited at initiation so the outbound lint set is configured before anything travels, never
  retrofitted after it has): {{SENSITIVITY_POSTURE}}
