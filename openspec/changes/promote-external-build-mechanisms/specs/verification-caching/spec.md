# Capability: verification-caching

What a cached verification result may be used for.

## ADDED Requirements

### Requirement: A cached result SHALL serve feedback only

A cached result SHALL serve feedback only, wherever a deployment introduces memoisation over its
checks — a task-runner cache, incremental verification, a result cache. The verdict anything is
cited on — an acceptance, a publication, a release gate's PASS — SHALL come from a direct, uncached
run, and the record citing it SHALL state that the run was direct. A cache key is a proxy for the
tree, and an under-keyed or stale entry returns a green that was true of another tree and is
indistinguishable from a pass.

The scope of this capability is a question stated for the owner in the drafted text: this standard
ships no cache, and whether it should govern a tooling class it does not ship is answered by the
owner push that publishes the version.

#### Scenario: An acceptance record cites a cached green

- **WHEN** an acceptance, publication or release verdict is supported only by a cached result
- **THEN** the record does not satisfy this requirement until a direct, uncached run is cited and
  stated as direct

#### Scenario: A cache is accepted into a deployment

- **WHEN** a deployment accepts a verification cache
- **THEN** its acceptance record proves invalidation in both directions — a change that must miss
  and an unchanged input that must still hit — and includes the named negative test: a defect the
  cache key does not capture, caught by the direct authoritative run
