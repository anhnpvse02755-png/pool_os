// EPIC 09 — User Settings response shapes (Track A — mobile app).

import 'package:pool_os/features/user_settings/domain/capability.dart';

class UserSettingsResponse {
  final String playerId;
  final DateTime generatedAt;
  final List<UserSettingsContribution> contributions;
  const UserSettingsResponse({
    required this.playerId,
    required this.generatedAt,
    this.contributions = const [],
  });
}

class UserSettingsContribution {
  final String engineId;
  final CapabilityStatus status;
  final CapabilityReason? reason;
  final Map<String, Object?> data;
  const UserSettingsContribution({
    required this.engineId,
    required this.status,
    this.reason,
    this.data = const {},
  });
  bool get isImplemented => status == CapabilityStatus.implemented;
}