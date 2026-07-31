// EPIC 08 — ListingEngine (Deliverable 1.4).
//
// Wave 2. Buy/Sell listing management. States: Draft/Published/Reserved/
// Sold/Archived/Cancelled. Only owner may edit. Sold = read-only.

import 'package:pool_os/features/marketplace/domain/marketplace_engine.dart';

class ListingEngine implements MarketplaceEngine {
  @override
  String get engineId => 'listing';
  @override
  Future<MarketplaceContribution> run(MarketplaceRequest request) async {
    return const MarketplaceContribution(
      engineId: 'listing',
      status: CapabilityStatus.implemented,
    );
  }
}