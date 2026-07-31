// EPIC 06 — Provider for CoachService.
//
// UI consumers (coach_screen.dart etc.) call `coachServiceProvider` and
// receive a CoachService. No widget reaches engines, providers, or
// data sources directly.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/coach/domain/coach_pipeline.dart';
import 'package:pool_os/features/coach/domain/coach_service.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';

/// Provider for the LLM Provider Adapter. Default = MockAI.
final llmProviderAdapterProvider = Provider<LlmProviderAdapter>(
  (ref) => LlmProviderRegistry.defaultProvider,
);

/// Provider for the CoachPipeline. Composed from the LLM adapter and
/// the six engines. Wave 1 ships Recommendation; Waves 2 and 3 add the
/// remaining five in [CoachPipeline] directly.
final coachPipelineProvider = Provider<CoachPipeline>(
  (ref) => defaultCoachPipeline(ref.watch(llmProviderAdapterProvider)),
);

/// The sole UI-facing entry point of the AI Coach layer.
final coachServiceProvider = Provider<CoachService>(
  (ref) => CoachService(ref.watch(coachPipelineProvider)),
);