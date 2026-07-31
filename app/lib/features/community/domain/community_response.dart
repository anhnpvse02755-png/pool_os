// EPIC 07 — canonical response shape for CommunityService.

import 'package:pool_os/features/community/domain/capability.dart';

class CommunityResponse {
  final String playerId;
  final DateTime generatedAt;
  final List<CommunityContribution> contributions;

  const CommunityResponse({
    required this.playerId,
    required this.generatedAt,
    this.contributions = const <CommunityContribution>[],
  });
}

class CommunityContribution {
  final String engineId;
  final CapabilityStatus status;
  final CapabilityReason? reason;
  final Map<String, Object?> data;

  const CommunityContribution({
    required this.engineId,
    required this.status,
    this.reason,
    this.data = const <String, Object?>{},
  });

  bool get isImplemented => status == CapabilityStatus.implemented;
}
