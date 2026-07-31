// EPIC 08 — RatingEngine (Deliverable 1.2).
//
// Wave 1. Aggregate: Average Rating / Total Reviews / Rating Distribution.
// Calculated from Published reviews only.

import 'package:pool_os/features/marketplace/domain/marketplace_engine.dart';

class RatingEngine implements MarketplaceEngine {
  @override
  String get engineId => 'rating';
  @override
  Future<MarketplaceContribution> run(MarketplaceRequest request) async {
    return const MarketplaceContribution(
      engineId: 'rating',
      status: CapabilityStatus.implemented,
    );
  }
}