// EPIC 08 — canonical response shape.

import 'package:pool_os/features/marketplace/domain/capability.dart';

class MarketplaceResponse {
  final String playerId;
  final DateTime generatedAt;
  final List<MarketplaceContribution> contributions;
  const MarketplaceResponse({
    required this.playerId,
    required this.generatedAt,
    this.contributions = const [],
  });
}

class MarketplaceContribution {
  final String engineId;
  final CapabilityStatus status;
  final CapabilityReason? reason;
  final Map<String, Object?> data;
  const MarketplaceContribution({
    required this.engineId,
    required this.status,
    this.reason,
    this.data = const {},
  });
  bool get isImplemented => status == CapabilityStatus.implemented;
  bool get isPlanned => status == CapabilityStatus.planned;
}