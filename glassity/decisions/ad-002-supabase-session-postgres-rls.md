---
type: architecture-decision
title: AD-002 — Supabase identity, server-side tenant binding, and PostgreSQL RLS
description: Selects the v1 IAM, session authority, tenant-selection fact, database isolation boundary, and cross-tenant proof.
tags: [glassity, security, architecture, identity, multitenancy, ad-002]
resource: glassity/decisions/
timestamp: 2026-08-27
lifecycle: active
---

# AD-002 — Supabase identity, server-side tenant binding, and PostgreSQL RLS

## Status

**Approved by the accountable owner on 2026-08-27.** This resolves AD-002 at the security-design layer only. It does not assert that IAM, sessions, RLS policies, route coverage, or cross-tenant tests exist, and it does not approve application implementation, production release, or residual risk.

The evidence base establishes separate production and staging PostgreSQL databases with no data syncing between them (`KM-Glassity-Company/working-docs/product/product-knowledge.md`). The Glassity CEO also named Supabase as a component of the Junox work-stream on 2026-08-19 (Company-hub commit `5acde5519dfac2e0f4b4464af3618bcf4141343c`, Junox change and glossary entries), but that statement does not confirm Supabase as the application's identity layer. No formal IAM selection is on record, and confirmation with the accountable product owner remains open. This decision selects Supabase Auth for v1; discovery of a deployed provider is evidence for a governed amendment, not permission for a builder to substitute one silently.

## Decision in two sentences

The sole tenant-selection fact is `tenant_sessions.active_tenant_id`, held server-side against a validated Supabase Auth `session_id` and `sub` after an active membership check; URLs, headers, prompts, client fields, object metadata, and Git paths never provide tenant authority.

A route-inventory test authenticates a valid tenant-A user and exercises every tenant-scoped tenant-B route, asserting denial, zero returned tenant-B data, zero mutation, and an attributable denied audit event; direct PostgreSQL tests independently prove the same boundary under row-level security.

## Identity and session contract

1. Supabase Auth authenticates human users and issues the access and refresh tokens. Glassity does not implement passwords, token signing, refresh-token rotation, or identity recovery.
2. The application server validates the access token with the provider's supported server library and verifies signature, issuer, audience, expiry, not-before time, `session_id`, and `sub`. A locally decoded or unvalidated session object is never authorization evidence.
3. `tenant_sessions` is a server-only store keyed by the validated Supabase `session_id`. Its binding contains the authenticated `sub`, one `active_tenant_id`, membership/version evidence, creation and expiry times, and revocation state. It has no browser grant; only the authorization resolver may read or change it, and the tenant request database role cannot.
4. Initial tenant activation and every tenant switch re-check an active `tenant_memberships` row before writing the binding. One provider session has exactly one active tenant, so a switch applies to every tab sharing that session. The binding version changes atomically and is revoked when the provider session, user, tenant, or membership is disabled.
5. The browser may request a tenant by opaque identifier or slug only as a selection attempt. Until the server resolves it and writes the binding, that value has no authority. Subsequent tenant-scoped requests use only the server-side binding.
6. Missing, expired, revoked, ambiguous, or mismatched identity or tenant context fails closed before business logic. Cookie-based calls use secure session-cookie and CSRF/origin controls; bearer calls never accept identity or tenant values outside the verified token and server binding.

## Database isolation contract

- Every tenant-owned application table carries a non-null immutable `tenant_id` participating in its keys and indexes.
- PostgreSQL row-level security is enabled and forced on every tenant table. The application role is not a superuser, table owner with an exemption, or a role with `BYPASSRLS`.
- At request start, the authorization resolver reads one binding version. Each database transaction pins the resulting subject and tenant context for its full lifetime; a concurrent switch can affect the next request but cannot change a transaction in flight. RLS checks both `tenant_id` equality and an active membership; request parameters are not copied into database authorization context.
- Tenant request paths never use Supabase secret/service credentials or any other RLS-bypassing role. Administrative migrations and break-glass operations are separate, audited paths and cannot serve tenant HTTP requests.
- Tenant tables are not directly exposed through a browser Data API. Views use the invoker's security context or have grants revoked; functions cannot reintroduce an owner/security-definer bypass.
- A resource identifier that resolves to another tenant is denied without returning tenant-B attributes. Whether the HTTP surface uses `403` or `404` is fixed by the future API contract, but all routes use one response policy.

## Required proof

### Route completeness and cross-tenant denial

The future app contract maintains a machine-readable inventory of every tenant-scoped route, method, and mutation class. CI fails if a route is added without an inventory entry and a cross-tenant case.

The canonical negative fixture creates tenant A, tenant B, a valid user with active membership only in A, an authenticated Supabase session bound to A, and representative B resources. It invokes every B route and method and proves:

- no B record, count, identifier, timing-dependent detail, pointer, file, answer, event, or Git location is returned;
- no B row, object, answer, event, queue item, audit success, or Git state is created, changed, or deleted;
- the request is denied under the route's fixed `403`/`404` policy; and
- a minimized audit event records actor, session, attempted tenant, active tenant, route, correlation ID, and denial reason without restricted payloads.

### Database isolation

Direct SQL tests run as the production application role with tenant-A context and attempt `SELECT`, `INSERT`, `UPDATE`, and `DELETE` against tenant-B rows. They must return no B data and create no effect. Separate canaries prove that removing RLS, adding `BYPASSRLS`, using an unsafe view/function, omitting tenant context, or substituting a request-supplied tenant causes the security test to fail.

### Identity and lifecycle

Tests reject forged, expired, wrong-issuer, wrong-audience, missing-session, and session-fixed tokens; revoked memberships and tenant switches take effect through the server binding without waiting for stale tenant authorization in a JWT to expire. Concurrent tabs observe the one active tenant for their shared provider session, and version-race tests prove every request and transaction uses exactly one identity/binding snapshot.

## Alternatives considered

### Clerk Organizations with PostgreSQL RLS

Not selected for v1. Clerk provides an active organization in its session model, but it would add a second provider when Supabase can supply both established identity and PostgreSQL authorization primitives. It remains a governed migration option if the existing app is later shown to use it.

### Auth0 Organizations with PostgreSQL RLS

Not selected for v1. It offers mature enterprise federation but adds configuration, cost, and a second control plane without a demonstrated first-version need.

### Application query filters

Rejected. Remembering `WHERE tenant_id = ...` in every repository or handler cannot fail closed when a route omits the filter and does not protect alternate database access paths.

### Tenant authorization stored only in JWT claims

Rejected. Membership and active-tenant changes would remain stale until token refresh. The verified JWT establishes identity and provider session; the current tenant binding and membership remain server-side.

## Consequences and gates

- AD-002 is complete at the design layer. SEC-001 and SEC-002 remain unimplemented, and VER-001, VER-002, and relevant VER-012 cases remain release blockers.
- AD-002 governs human browser and application HTTP paths only. Worker tenant context and non-human job authorization remain outside this decision and must be specified by the worker contract under AD-001 and AD-004 while still satisfying SEC-002.
- Future app/API and cockpit contracts must encode this identity, session, route-inventory, denial, audit, and RLS boundary before implementation.
- AD-003 through AD-005 remain unresolved and blocking. In particular, AD-004 must govern provider keys, server-session storage credentials, database roles, rotation, revocation, and break-glass access.
- If an existing production IdP is later identified, it may replace Supabase only through a governed amendment proving equivalent server-side token validation. The `tenant_sessions.active_tenant_id` authority, membership re-check, RLS boundary, and negative-test oracle do not change.
- No residual risk from TM-001, TM-011, TM-018, or any other Phase S0 threat is accepted here.

## References

Accessed 2026-08-27:

- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Supabase server-side authentication](https://supabase.com/docs/guides/auth/server-side)
- [Supabase server token validation guidance](https://supabase.com/docs/guides/auth/server-side/creating-a-client)
- [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [PostgreSQL row security documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
