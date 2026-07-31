// EPIC 06 — RecommendationEngine (Deliverable 2.2).
//
// PO 2026-07-31 Wave 1. Wraps the existing
// `coach_recommendation_engine.dart` + `coach_recommendation_builder.dart`
// + the AdaptiveRecommendationEngine into a single CoachEngine surface
// that the CoachPipeline can address uniformly.

import 'package:pool_os/features/coach/domain/coach_engine.dart';
import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';
import 'package:pool_os/features/coach/domain/llm/capability.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';
import 'package:pool_os/features/coach/domain/coach_recommendation_engine.dart';
import 'package:pool_os/features/coach/domain/adaptive_recommendation_engine.dart';

class RecommendationEngine implements CoachEngine {
  final CoachRecommendationEngine _legacy;
  final AdaptiveRecommendationEngine _adaptive;
  final LlmProviderAdapter _llm;

  const RecommendationEngine({
    required CoachRecommendationEngine legacy,
    required AdaptiveRecommendationEngine adaptive,
    required LlmProviderAdapter llm,
  })  : _legacy = legacy,
        _adaptive = adaptive,
        _llm = llm;

  @override
  String get engineId => 'recommendation';

  @override
  Future<CoachEngineContribution> run(CoachRequest request) async {
    // Phase 1: deterministic projection. The legacy engine is referenced
    // for future wiring; the concrete call sites land in Phase 6.6 when
    // AI data sources are plumbed in.
    final llmResult = _llm.complete(LlmRequest(
      capabilityId: 'recommendation.summary',
      prompt: 'Synthesize today\'s recommendation from the AI inputs.',
      context: <String, Object?>{'playerId': request.playerId},
    ));

    if (llmResult.isImplemented) {
      return CoachEngineContribution(
        engineId: engineId,
        status: CapabilityStatus.implemented,
        content: <String, Object?>{
          'llm': llmResult.value?.text,
        },
      );
    }
    return CoachEngineContribution(
      engineId: engineId,
      status: CapabilityStatus.notAvailable,
      reason: llmResult.reason,
      content: const <String, Object?>{},
    );
  }
}