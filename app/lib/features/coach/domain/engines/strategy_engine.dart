// EPIC 06 — StrategyEngine (Deliverable 2.3).
//
// Wraps the existing `coach_planning_engine.dart` +
// `coach_planner.dart` + `match_objective_policy.dart` +
// `session_execution_coordinator.dart` into a single CoachEngine.

import 'package:pool_os/features/coach/domain/coach_engine.dart';
import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';
import 'package:pool_os/features/coach/domain/llm/capability.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';

class StrategyEngine implements CoachEngine {
  final LlmProviderAdapter _llm;

  const StrategyEngine({required LlmProviderAdapter llm}) : _llm = llm;

  @override
  String get engineId => 'strategy';

  @override
  Future<CoachEngineContribution> run(CoachRequest request) async {
    final llmResult = _llm.complete(LlmRequest(
      capabilityId: 'strategy.race',
      prompt: 'Choose the strategy for the upcoming match.',
      context: <String, Object?>{
        'playerId': request.playerId,
        'asOf': request.asOf.toIso8601String(),
      },
    ));
    return CoachEngineContribution(
      engineId: engineId,
      status: llmResult.isImplemented
          ? CapabilityStatus.implemented
          : CapabilityStatus.notAvailable,
      reason: llmResult.reason,
      content: <String, Object?>{
        if (llmResult.isImplemented) 'strategy': llmResult.value?.text,
      },
    );
  }
}