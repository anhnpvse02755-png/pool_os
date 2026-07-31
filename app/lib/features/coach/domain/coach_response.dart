// EPIC 06 — canonical response shape for every CoachService entry point.

import 'package:pool_os/features/coach/domain/llm/capability.dart';

class CoachEngineContribution {
  final String engineId;
  final CapabilityStatus status;
  final CapabilityReason? reason;
  final Map<String, Object?> content;

  const CoachEngineContribution({
    required this.engineId,
    required this.status,
    this.reason,
    this.content = const <String, Object?>{},
  });

  bool get isImplemented => status == CapabilityStatus.implemented;
}

class CoachResponse {
  final String playerId;
  final DateTime generatedAt;
  final String summary;
  final List<CoachEngineContribution> contributions;

  const CoachResponse({
    required this.playerId,
    required this.generatedAt,
    required this.summary,
    this.contributions = const <CoachEngineContribution>[],
  });
}