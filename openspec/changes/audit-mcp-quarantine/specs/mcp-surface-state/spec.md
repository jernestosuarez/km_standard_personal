# Capability: mcp-surface-state

Whether the optional query surface serves or refuses, how that state is declared, and what it does
when it cannot enforce the access contract the standard requires of a consuming surface.

## ADDED Requirements

### Requirement: A surface that cannot enforce its contract refuses to serve

The optional query surface SHALL refuse to answer while it is quarantined, and SHALL NOT return entity
content, listings, or query results in that state. Refusing is the correct behaviour for a surface
whose contract it cannot keep, and serving under an unenforceable contract is a defect.

#### Scenario: A quarantined surface receives an entity request

- **WHEN** the surface is quarantined and a caller requests an entity by identifier
- **THEN** the surface refuses
- **AND** it returns no entity content
- **AND** it states that it is quarantined and why

#### Scenario: A quarantined surface receives a query

- **WHEN** the surface is quarantined and a caller submits a query
- **THEN** the surface refuses
- **AND** it returns no matched content

#### Scenario: A quarantined surface receives a listing request

- **WHEN** the surface is quarantined and a caller requests a listing
- **THEN** the surface refuses
- **AND** it returns no entity records

### Requirement: The quarantine is discoverable before it is relied on

The surface SHALL declare its quarantined state where an operator will encounter it before enabling
the surface, and SHALL state it again when the surface is started. An operator SHALL NOT have to read
the implementation to discover that the surface does not serve.

#### Scenario: An operator reads the surface documentation

- **WHEN** an operator reads the surface's own documentation
- **THEN** the quarantined state is stated there
- **AND** the reason is given

#### Scenario: An operator starts the surface

- **WHEN** the surface is started while quarantined
- **THEN** it reports that it is quarantined rather than starting silently

### Requirement: The quarantine names the exposure it closes

The quarantine record SHALL state which content classes were reachable by which path before it was
applied, so a deployment can assess what it ran. It SHALL NOT describe the exposure in general terms
where the specific path is known.

#### Scenario: A deployment assesses its own history

- **WHEN** a deployment that had enabled the surface reads the quarantine record
- **THEN** it can determine which retrieval paths applied which gates
- **AND** it can determine which content classes were reachable by each path

### Requirement: Commitment is not clearance

The surface SHALL NOT treat the fact that content is committed as evidence that the content may be
disclosed to a caller. Committed state establishes that a fact is recorded, and it does not establish
lifecycle currency, access clearance, or manifest membership.

#### Scenario: Committed content that is not cleared

- **WHEN** content is committed at `HEAD` but is retired, superseded, restricted, sensitive, or absent
  from the projection manifest
- **THEN** the surface does not disclose it on the grounds that it is committed

### Requirement: The quarantine is lifted only against a proved contract

The quarantine SHALL remain in force until every gate the standard requires is implemented on every
content-returning path and proved by negative test. It SHALL NOT be lifted by a change that repairs
one path while leaving another unguarded.

#### Scenario: A partial repair is offered

- **WHEN** a change enforces the required gates on some content-returning paths and not others
- **THEN** the quarantine is not lifted

#### Scenario: A proved repair is offered

- **WHEN** a change enforces every required gate on every content-returning path
- **AND** each excluded content class is proved unreachable by identifier lookup and by query
- **THEN** the quarantine may be lifted
