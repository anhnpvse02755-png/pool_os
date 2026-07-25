# Pool OS Contributor Rules

All human and AI contributors must read `ARCHITECTURE_CONSTITUTION.md` before
making architectural, cross-domain, data-contract, Knowledge, Evidence,
Intelligence, Simulation, or Experience changes.

## Required Before Editing

1. Identify the owning domain for every model and behavior being changed.
2. List each cross-domain contract affected by the change.
3. Preserve semantic IDs, versions, provenance, and compatibility rules.
4. Use public ports/contracts; never import another domain's persistence or
   internal implementation.
5. Check the Explicit Prohibitions section of the constitution.
6. Run `dart run tool/architecture_test.dart` for cross-domain changes.

## Implementation Guardrails

- Pool OS is a modular monolith until operational evidence justifies extraction.
- Knowledge authoring is the source of truth; generated JSON is never edited by hand.
- Evidence facts are distinct from Intelligence inferences and decisions.
- Experience renders projections and sends commands; it does not infer Mastery or recommendations.
- Simulation contains physics, not player models, strategy, Coach policy, or UI.
- AI-generated content cannot self-review, self-verify, or self-publish.
- Natural-language explanations must be grounded in a structured Decision Trace.

When a requested change conflicts with the constitution, stop and surface the
conflict. Do not silently work around it. Constitutional amendments require the
process defined in Section 20 of `ARCHITECTURE_CONSTITUTION.md`.

Durable architecture decisions must use `architecture/adr/ADR_TEMPLATE.md` and
must cite both normative authority and architecture evidence.

## Contributor Role Routing

- A task assigned the Product Owner role must bootstrap from
  `architecture/product/PO_BOOTSTRAP.md`, then read the current Handoff,
  authoritative Roadmap, active FEATURE specification, and relevant leading
  section of `MEMORY.md` before acting.
- Product Owner plans, records authoritative product documents, authorizes
  Engineering, reviews Engineering Reports, and authorizes closure. Product
  Owner does not implement Dart, schema, or tests and does not repeat adequate
  Engineering verification unless evidence is missing or contradictory.
- A task assigned the Code/Engineering role implements only the current written
  authorization, reports evidence before any commit or push, and never expands
  the Roadmap or opens the next FEATURE by inference.
- Tracked product contracts override chat and task history. Communication
  history cannot authorize work that the Roadmap, active FEATURE, and Handoff do
  not authorize.
