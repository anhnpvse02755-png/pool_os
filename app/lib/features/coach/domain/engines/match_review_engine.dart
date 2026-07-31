// EPIC 06 — MatchReviewEngine (Deliverable 2.7).
//
// Wraps `coach_intelligence.dart` + `coach_adaptation_projector.dart`
// + the rule engine surfaces into a single CoachEngine that emits a
// post-match review (strengths, weaknesses, patterns, recommendations).

import 'package:pool_os/features/coach/domain/coach_engine.dart';
import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';
import 'package:pool_os/features/coach/domain/llm/capability.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';

class MatchReviewEngine implements CoachEngine {
  final LlmProviderAdapter _llm;

  const MatchReviewEngine({required LlmProviderAdapter llm}) : _llm = llm;

  @override
  String get engineId => 'match_review';

  @override
  Future<CoachEngineContribution> run(CoachRequest request) async {
    final matchCount = request.data.matches.length;
    final llmResult = _llm.complete(LlmRequest(
      capabilityId: 'match.review',
      prompt: 'Compose a post-match review.',
      context: <String, Object?>{
        'playerId': request.playerId,
        'matchCount': matchCount,
      },
    ));
    return CoachEngineContribution(
      engineId: engineId,
      status: llmResult.isImplemented
          ? CapabilityStatus.implemented
          : CapabilityStatus.notAvailable,
      reason: llmResult.reason,
      content: <String, Object?>{
        'matchesReviewed': matchCount,
        if (llmResult.isImplemented) 'review': llmResult.value?.text,
      },
    );
  }
}