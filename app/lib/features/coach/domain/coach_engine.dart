// EPIC 06 — CoachEngine abstract + the six concrete engines.
//
// Every engine takes a CoachRequest and produces a CoachEngineContribution.
// Engines NEVER call LLM directly — they go through LlmProviderAdapter.

import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';

abstract class CoachEngine {
  String get engineId;

  Future<CoachEngineContribution> run(CoachRequest request);
}