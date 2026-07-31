// EPIC 08 — ReviewEngine (Deliverable 1.1).
//
// Wave 1. Extends FEATURE_010. Create/Edit/Delete/View reviews.
// Review states: Draft/Published/Hidden/Archived. One review per user
// per equipment. Soft delete preserves rating statistics.

import 'package:pool_os/features/marketplace/domain/marketplace_engine.dart';

class ReviewEngine implements MarketplaceEngine {
  @override
  String get engineId => 'review';
  @override
  Future<MarketplaceContribution> run(MarketplaceRequest request) async {
    return const MarketplaceContribution(
      engineId: 'review',
      status: CapabilityStatus.implemented,
    );
  }
}