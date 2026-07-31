// EPIC 06 — TrainingEngine (Deliverable 2.6).
//
// Uses `learning_runtime` projections, `coach_planning_engine`, and
// the existing training session builder to emit a program / weekly /
// daily plan. Phase 6.6 wires these to live data; Wave 3 wraps the
// surfaces.

import 'package:pool_os/features/coach/domain/coach_engine.dart';
import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';
import 'package:pool_os/features/coach/domain/llm/capability.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';

class TrainingEngine implements CoachEngine {
  final LlmProviderAdapter _llm;

  const TrainingEngine({required LlmProviderAdapter llm}) : _llm = llm;

  @override
  String get engineId => 'training';

  @override
  Future<CoachEngineContribution> run(CoachRequest request) async {
    final programCount = request.data.programs.length;
    final llmResult = _llm.complete(LlmRequest(
      capabilityId: 'training.suggest',
      prompt: 'Build a 7-day training program.',
      context: <String, Object?>{
        'playerId': request.playerId,
        'programCount': programCount,
      },
    ));
    return CoachEngineContribution(
      engineId: engineId,
      status: llmResult.isImplemented
          ? CapabilityStatus.implemented
          : CapabilityStatus.notAvailable,
      reason: llmResult.reason,
      content: <String, Object?>{
        'programsConsidered': programCount,
        if (llmResult.isImplemented) 'plan': llmResult.value?.text,
      },
    );
  }
}