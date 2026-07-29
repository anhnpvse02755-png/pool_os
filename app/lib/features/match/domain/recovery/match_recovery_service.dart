// EPIC 01 — Match Engine — Phase 7 (recovery service).
//
// Recovery service that rehydrates a MatchManager from the persisted
// event log. The service is intentionally minimal: replay the event
// log forward to rebuild the snapshot, then yield the manager to the
// caller.
//
// The service exposes a stable async surface so the presentation layer
// can use it directly.

import '../engine/match_aggregate.dart';
import '../engine/match_event_log.dart';
import '../engine/match_manager.dart';
import '../rule/placeholder_rule.dart';

class MatchRecoveryService {
  const MatchRecoveryService({
    required this.eventLog,
    required this.ruleRegistry,
  });

  final MatchEventLog eventLog;
  final GameRuleRegistry ruleRegistry;

  Future<MatchManager> hydrate(Match initial) async {
    final builder = MatchManagerBuilder(
      eventLog: eventLog,
      ruleRegistry: ruleRegistry,
    );
    return builder.hydrate(initial);
  }

  Future<MatchManager> build(Match initial) async {
    final builder = MatchManagerBuilder(
      eventLog: eventLog,
      ruleRegistry: ruleRegistry,
    );
    return builder.buildNew(initial);
  }
}
