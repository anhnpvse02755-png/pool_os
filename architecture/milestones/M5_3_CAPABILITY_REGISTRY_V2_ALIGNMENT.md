# Capability Registry v2 Alignment

**Status:** Accepted; Closed

**Date:** 2026-07-22

## Scope

Product Owner approved an additive Registry v2 alignment before M5.3. The
existing frozen `AICapabilityRegistryContract` v1 remains unchanged. The new
v2 contract is the authoritative source for `allowedToolIds`, optional
`defaultToolId`, and a fixed `AIToolInvocationPolicyV2` enum.

## Evidence

- Registry v2 canonicalizes capability and tool identities and rejects duplicate,
  invalid, unsupported, or non-canonical declarations.
- Registry v2 exposes deterministic `definitionFor` lookup for M5.3 planning.
- v1 artifacts remain readable with explicit empty tool policy; v2 round-trip
  verifies identity and digest.
- PromptRendering v2 remains unchanged and remains the only rendering input.
- M3 frozen contracts, manifest, proof, Golden Fixtures, Knowledge, and prior
  M3/M4 identities are unchanged.
- Focused Registry v2 alignment tests: 4/4.
- Full app regression: 384/384.
- Knowledge package regression: 75/75.
- M3 Foundation Freeze: PASS.
- Architecture Fitness: 133 existing / 0 new.
- Analyzer: clean for the v2 contract and focused tests.
- `git diff --check`: PASS.

No alignment commit or push has been performed before Product Owner review.

## Product Review

Product Owner accepted and closed this alignment on 2026-07-22. PromptRendering
v2 and Capability Registry v2 are the official M5.3 baseline.
