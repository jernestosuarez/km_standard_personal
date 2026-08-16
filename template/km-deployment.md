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
