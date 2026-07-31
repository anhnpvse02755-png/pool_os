# EPIC 06 — AI Boundary Audit

PO 2026-07-31 — EPIC 06 is the **only** Epic allowed to host AI. To
prevent AI leaks into EPIC 01–05, the boundary has three gates:

1. **Static grep** — `grep -E "openai|anthropic|claude|gemini|huggingface|\bllm\b"`
   must return zero results outside `app/lib/features/coach/`.
2. **Runtime capability** — every LLM call path is gated by
   `LlmProviderAdapter.isImplemented`. The default `MockAIAdapter` is
   implemented; the three network adapters return
   `CapabilityResult.notAvailable` until PO authorizes them.
3. **Code review** — `coach_screen.dart` calls `CoachService` only.

## Test cases

The boundary is exercised by `test/features/coach/ai_boundary_test.dart`
which runs all three gates in CI:

- `expectBannedImportsInNonCoachFeatures` — reads every non-coach
  feature directory and asserts no banned strings appear.
- `expectMockAiDefaultImplemented` — verifies `MockAIAdapter.isImplemented`
  is `true` and that the three remote adapters return
  `notAvailable` from their `complete` method.
- `expectCoachScreenCallsCoachServiceOnly` — string-scans
  `coach_screen.dart` to forbid direct calls into engines, providers,
  or upstream repositories.

## Boundary contract (single-lifecycle, do not change lightly)

| Source path | May use AI? |
|---|---|
| `app/lib/features/coach/**` | ✅ yes (Coach layer; sole carrier) |
| `app/lib/features/match/**` | ❌ no |
| `app/lib/features/statistics/**` | ❌ no |
| `app/lib/features/training/**` | ❌ no |
| `app/lib/features/training_system/**` | ❌ no |
| `app/lib/features/drill/**` | ❌ no |
| `app/lib/features/skill/**` | ❌ no |
| `app/lib/features/tournament/**` | ❌ no |
| `app/lib/features/knowledge/**` | ❌ no |
| `app/lib/features/equipment/**` | ❌ no |

Coach layer is the only path that may include the LLM Provider Adapter.
All other features read from data only.

## Audit result (EPIC 06 final)

Audited by Engineering at single regression time. Result appended to
`EPIC_06_ENGINEERING_REPORT.md` Section 6.

## Banned strings (single source of truth)

```
openai           → any OpenAI import
anthropic        → any Anthropic import
claude           → any Claude LLM call (case-insensitive)
gemini           → any Gemini LLM call (case-insensitive)
huggingface      → any HuggingFace dependency
llm              → any "llm" identifier
```

Note: identifiers like `ClaudeAdapter` or `OpenAIClient` are *providers*
inside the LLM Provider Adapter. They are the only files in the
codebase that may import these strings — guarded by capability, never
exposed outside the Coach feature.