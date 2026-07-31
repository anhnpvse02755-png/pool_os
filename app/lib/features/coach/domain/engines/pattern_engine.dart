// EPIC 06 — PatternEngine (Deliverable 2.4).
//
// Reads shot / position / miss history via AiDataSnapshot (provided by
// Phase 6.6 data wiring) and emits a deterministic pattern list. LLM
// is used in MockAI mode to render the pattern narrative for tests.

import 'package:pool_os/features/coach/domain/coach_engine.dart';
import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';
import 'package:pool_os/features/coach/domain/llm/capability.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';

class PatternEngine implements CoachEngine {
  final LlmProviderAdapter _llm;

  const PatternEngine({required LlmProviderAdapter llm}) : _llm = llm;

  @override
  String get engineId => 'pattern';

  @override
  Future<CoachEngineContribution> run(CoachRequest request) async {
    // Deterministic sample — Phase 6.6 replaces these stubs with
    // real shot/position/miss projections from the AiDataSnapshot.
    final patternCount = request.data.matches.length;

    final llmResult = _llm.complete(LlmRequest(
      capabilityId: 'pattern.detect',
      prompt: 'Detect the most frequent pattern from history.',
      context: <String, Object?>{
        'playerId': request.playerId,
        'matchCount': patternCount,
      },
    ));
    return CoachEngineContribution(
      engineId: engineId,
      status: llmResult.isImplemented
          ? CapabilityStatus.implemented
          : CapabilityStatus.notAvailable,
      reason: llmResult.reason,
      content: <String, Object?>{
        'patternsAnalyzed': patternCount,
        if (llmResult.isImplemented) 'narrative': llmResult.value?.text,
      },
    );
  }
}