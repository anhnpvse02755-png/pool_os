# Billiard Knowledge

Billiard Knowledge is the versioned knowledge source used by Pool OS. The
package owns content schema, validation, search, relationships, learning paths,
and provenance. It does not own training records, Coach decisions, or UI.

Pack v1.3 contains 36 bilingual Pool entries across fundamentals, aiming,
cue-ball control, position play, safety, break, rules, equipment, common
mistakes, Vietnamese table terminology, and the mental game. Four learning paths
cover beginner fundamentals, cue-ball control, pattern/safety play, and match
essentials.

New content is added only after it has sources, a review state, and passes
catalog validation. From this package, run `dart run tool/expand_pack_v1.dart`
and then `dart run tool/enrich_pack_v1_3.dart` to rebuild the v1 asset
deterministically.

## Five Explanation Levels

1. `result`: follow these actions without theory.
2. `cause`: understand why the action changes the outcome.
3. `principles`: connect friction, sliding, rolling, and shot behavior.
4. `physics`: inspect vectors, momentum, collision, and coefficients.
5. `engine`: translate the model into simulation state and algorithms.

Reviewed entries must include levels 1-3. Levels 4-5 are optional and are
published only when their technical content has been explicitly authored.

## Public API

```dart
final catalog = KnowledgeCatalog.fromJsonString(json);
final results = catalog.search(const KnowledgeQuery(text: 'cau tay'));
final path = catalog.pathById('path.beginner.fundamentals');
```

Pool OS loads `packages/billiard_knowledge/assets/pack_v1.json` from Flutter's
package asset namespace and consumes the
package through `package:billiard_knowledge/billiard_knowledge.dart`.

## Content Rules

- Stable semantic IDs never change after publication.
- User-facing explanations are original summaries, not copied source text.
- Every published entry has at least one source citation.
- Explanation layers progress from action to cause to principles.
- Draft content remains visibly draft and cannot silently become verified.
- Drill references are external IDs; this package does not duplicate drill
  implementations or player progress.
