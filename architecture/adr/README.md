# Architecture Decision Records

ADRs record durable architecture decisions. They do not override the Pool OS
Architecture Constitution.

Create ADRs from `ADR_TEMPLATE.md` and number them sequentially:

```text
ADR-001-short-title.md
ADR-002-short-title.md
```

An ADR must connect two different concerns:

- **Normative Authority:** why the decision is permitted and which contract it obeys.
- **Architecture Evidence:** how conformance is tested or observed.

Production behavior is evidence of what currently happens, not authority for
what is allowed. When evidence conflicts with authority, record drift or an
incident and fix the implementation or ratify an amendment.

ADRs are append-only historical decisions. Supersede an accepted decision with a
new ADR rather than rewriting its context or decision. Evidence status and links
may be updated as tests, metrics, and health reports evolve.
