// EPIC 06 — CoachPipeline (Wave 1).
//
// PO 2026-07-31 — orchestrator between CoachService and the 6 engines.
// Single-lifecycle EPIC: this file is the Wave 1 skeleton; Waves 2 and
// 3 register the remaining engines as concrete implementations. Until
// then, a run only invokes the engines that exist; missing engines
// emit a `planned` contribution so the UI gets a deterministic shape.

import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';
import 'package:pool_os/features/coach/domain/engines/recommendation_engine.dart';
import 'package:pool_os/features/coach/domain/llm/capability.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';
import 'package:pool_os/features/coach/domain/coach_recommendation_engine.dart';
import 'package:pool_os/features/coach/domain/adaptive_recommendation_engine.dart';

class CoachPipeline {
  final LlmProviderAdapter _llm;

  /// Currently registered engines. Waves 2 + 3 will add the rest.
  final List<CoachEnginePlus> engines;

  const CoachPipeline({
    required LlmProviderAdapter llm,
    this.engines = const <CoachEnginePlus>[],
  }) : _llm = llm;

  Future<CoachResponse> _aggregate(
    String playerId,
    DateTime now,
    CoachRequest request, {
    required List<String> plannedEngines,
  }) async {
    final contributions = <CoachEngineContribution>[];
    for (final id in plannedEngines) {
      final engine = engines.where((e) => e.engineId == id).firstOrNull;
      if (engine == null) {
        contributions.add(CoachEngineContribution(
          engineId: id,
          status: CapabilityStatus.planned,
          reason: const CapabilityReason(
            code: 'planned_post_wave_1',
            message:
                'This engine surfaces in Wave 2 or Wave 3 of EPIC 06.',
          ),
        ));
        continue;
      }
      final c = await engine.run(request);
      contributions.add(c);
    }
    return CoachResponse(
      playerId: playerId,
      generatedAt: now,
      summary: _summarize(contributions),
      contributions: contributions,
    );
  }

  String _summarize(List<CoachEngineContribution> contributions) {
    final implemented =
        contributions.where((c) => c.isImplemented).map((c) => c.engineId);
    return 'AI Coach: ${implemented.length}/${contributions.length} engines served.';
  }

  Future<CoachResponse> runCoachDaily(CoachRequest request) {
    return _aggregate(
      request.playerId,
      request.asOf,
      request,
      plannedEngines: const <String>[
        'recommendation',
        'strategy',
        'pattern',
        'training',
        'match_review',
      ],
    );
  }

  Future<CoachResponse> runRecommendation(CoachRequest request) {
    return _aggregate(
      request.playerId,
      request.asOf,
      request,
      plannedEngines: const <String>['recommendation'],
    );
  }

  Future<CoachResponse> runStrategy(CoachRequest request) {
    return _aggregate(
      request.playerId,
      request.asOf,
      request,
      plannedEngines: const <String>['strategy'],
    );
  }

  Future<CoachResponse> runPatternAnalysis(CoachRequest request) {
    return _aggregate(
      request.playerId,
      request.asOf,
      request,
      plannedEngines: const <String>['pattern'],
    );
  }

  Future<CoachResponse> runEquipmentSuggestion(CoachRequest request) {
    return _aggregate(
      request.playerId,
      request.asOf,
      request,
      plannedEngines: const <String>['equipment'],
    );
  }

  Future<CoachResponse> runTrainingSuggestion(CoachRequest request) {
    return _aggregate(
      request.playerId,
      request.asOf,
      request,
      plannedEngines: const <String>['training'],
    );
  }

  Future<CoachResponse> runMatchReview(CoachRequest request) {
    return _aggregate(
      request.playerId,
      request.asOf,
      request,
      plannedEngines: const <String>['match_review'],
    );
  }
}

/// Wraps an engine id so the pipeline can both look up by id and run.
class CoachEnginePlus {
  final String engineId;
  final Future<CoachEngineContribution> Function(CoachRequest) run;

  const CoachEnginePlus({required this.engineId, required this.run});
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

/// Convenience constructor for the Wave 1 Recommendation engine.
CoachPipeline defaultCoachPipeline(LlmProviderAdapter llm) {
  final rec = RecommendationEngine(
    legacy: CoachRecommendationEngine(),
    adaptive: AdaptiveRecommendationEngine(),
    llm: llm,
  );
  return CoachPipeline(llm: llm, engines: <CoachEnginePlus>[
    CoachEnginePlus(engineId: 'recommendation', run: rec.run),
  ]);
}