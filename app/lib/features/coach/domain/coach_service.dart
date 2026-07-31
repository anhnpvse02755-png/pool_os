// EPIC 06 — CoachService. THE sole entry point for the AI Coach layer.
//
// PO 2026-07-31 architecture:
//
//   UI → CoachService → CoachPipeline → 6 Engines → LlmProviderAdapter
//
// Strict rule: UI never reaches engines, AI providers, or any data
// source directly. CoachService is the only public surface of the AI
// Coach layer; everything else in this layer is internal to Wave 1.

import 'package:pool_os/features/coach/domain/coach_pipeline.dart';
import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';

class CoachService {
  final CoachPipeline _pipeline;

  const CoachService(this._pipeline);

  /// Aggregated answer to "what should I do today".
  Future<CoachResponse> coachDaily(CoachRequest request) {
    return _pipeline.runCoachDaily(request);
  }

  /// Aggregated recommendations.
  Future<CoachResponse> recommend(CoachRequest request) {
    return _pipeline.runRecommendation(request);
  }

  /// Aggregated strategy advice.
  Future<CoachResponse> adviseStrategy(CoachRequest request) {
    return _pipeline.runStrategy(request);
  }

  /// Pattern analysis.
  Future<CoachResponse> analyzePatterns(CoachRequest request) {
    return _pipeline.runPatternAnalysis(request);
  }

  /// Equipment suggestions.
  Future<CoachResponse> suggestEquipment(CoachRequest request) {
    return _pipeline.runEquipmentSuggestion(request);
  }

  /// Training suggestions.
  Future<CoachResponse> suggestTraining(CoachRequest request) {
    return _pipeline.runTrainingSuggestion(request);
  }

  /// Match review.
  Future<CoachResponse> reviewMatch(CoachRequest request) {
    return _pipeline.runMatchReview(request);
  }
}