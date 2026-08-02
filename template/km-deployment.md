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
---

# KM Deployment Binding

This hub was created from the canonical KM Standard revision recorded above.

`deployment-state: canonical` means no enterprise organization profile has been applied. Only an
authorized Supervisor may change the state to `organization-bound`, populate all four organization
and enterprise fields, and commit that customization separately.
