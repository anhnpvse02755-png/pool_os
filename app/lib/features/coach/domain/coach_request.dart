// EPIC 06 — canonical request shape for every CoachService entry point.

import 'package:pool_os/features/coach/domain/data_sources/ai_data_sources.dart';

class CoachRequest {
  final String playerId;
  final DateTime asOf;
  final AiDataSnapshot data;
  final Map<String, Object?> prefs;

  const CoachRequest({
    required this.playerId,
    required this.asOf,
    required this.data,
    this.prefs = const <String, Object?>{},
  });
}